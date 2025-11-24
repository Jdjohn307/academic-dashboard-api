require 'swagger_helper'

RSpec.describe 'Assignments API', swagger_doc: 'v1/swagger.yaml', type: :request do
  # Setup User Authentication
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let(:auth_headers) { auth_header_for(user) }

  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  path '/api/assignment/assignments' do
    parameter name: 'Authorization',
                in: :header,
                type: :string,
                required: true

    get 'List assignments' do
      tags 'Assignments'
      produces 'application/json'

      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'assignments listed default pagination' do
        let(:'options[page]')  { nil }
        let(:'options[limit]') { nil }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
          expect(json['meta']['page']).to eq(1)
          expect(json['meta']['count']).to eq(26)
          expect(json['meta']['next']).to eq(2)
          expect(json['meta']['from']).to eq(1)
          expect(json['meta']['to']).to eq(25)
          expect(json['meta']['last']).to eq(2)
        end
      end

      response '200', 'assignments listed with page + limit' do
        let(:'options[page]')  { 2 }
        let(:'options[limit]') { 10 }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(10)
          expect(json['meta']['page']).to eq(2)
          expect(json['meta']['count']).to eq(26)
          expect(json['meta']['next']).to eq(3)
          expect(json['meta']['from']).to eq(11)
          expect(json['meta']['to']).to eq(20)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'invalid page falls back to 1' do
        let(:'options[page]')  { -1 }
        let(:'options[limit]') { nil }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
          expect(json['meta']['page']).to eq(1)
          expect(json['meta']['count']).to eq(26)
          expect(json['meta']['next']).to eq(2)
          expect(json['meta']['from']).to eq(1)
          expect(json['meta']['to']).to eq(25)
          expect(json['meta']['last']).to eq(2)
        end
      end

      response '200', 'page param only' do
        let(:'options[page]')  { 2 }
        let(:'options[limit]') { nil }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json.fetch('data').length).to eq(1)
          expect(json['meta']['page']).to eq(2)
          expect(json['meta']['count']).to eq(26)
          expect(json['meta']['next']).to eq(nil)
          expect(json['meta']['from']).to eq(26)
          expect(json['meta']['to']).to eq(26)
          expect(json['meta']['last']).to eq(2)
        end
      end

      response '200', 'limit only' do
        let(:'options[page]')  { nil }
        let(:'options[limit]') { 5 }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json.fetch('data').length).to eq(5)
          expect(json['meta']['page']).to eq(1)
          expect(json['meta']['count']).to eq(26)
          expect(json['meta']['next']).to eq(2)
          expect(json['meta']['from']).to eq(1)
          expect(json['meta']['to']).to eq(5)
          expect(json['meta']['last']).to eq(6)
        end
      end

      response '200', 'page beyond last returns empty data' do
        let(:'options[page]')  { 5 }
        let(:'options[limit]') { 10 }
        let(:Authorization) { auth_headers["Authorization"] }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta']['page']).to eq(5)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'empty list' do
        let(:'options[page]')  { nil }
        let(:'options[limit]') { nil }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
        end
      end

      response '401', 'unauthorized' do
        let(:'options[page]')  { nil }
        let(:'options[limit]') { nil }
        let(:Authorization) { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('401')
          expect(json['errors'][0]['title']).to eq('Unauthorized')
          expect(json['errors'][0]['detail']).to match(/Invalid or expired token/)
        end
      end
    end

    post 'Create assignment' do
      tags 'Assignments'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          course_schedule_id: { type: :integer },
          due_date: { type: :string, format: :date_time },
          title: { type: :string },
          description: { type: :string },
          points_possible: { type: :number },
          status: { type: :string }
        },
        required: [ 'course_schedule_id', 'due_date', 'title', 'points_possible', 'status' ]
      }

      response '201', 'created' do
        let(:assignment) { attributes_for(:assignment).merge(course_schedule_id: course_schedule.id) }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'due_date', 'title', 'description', 'points_possible', 'status')
        end
      end

      response '422', 'missing' do
        let(:assignment) { {} }
        let(:Authorization) { auth_headers["Authorization"] }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'invalid' do
        let(:assignment) { attributes_for(:assignment, course_schedule_id: nil) }
        let(:Authorization) { auth_headers["Authorization"] }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('422')
          expect(json['errors'][0]['title']).to eq('Unprocessable Entity')
          expect(json['errors'][0]['detail']).to match(/Course schedule can't be blank/)
        end
      end

      response '401', 'unauthorized' do
        let(:assignment) { attributes_for(:assignment).merge(course_schedule_id: course_schedule.id) }
        let(:Authorization) { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('401')
          expect(json['errors'][0]['title']).to eq('Unauthorized')
          expect(json['errors'][0]['detail']).to match(/Invalid or expired token/)
        end
      end
    end
  end

  path '/api/assignment/assignments/{id}' do
    parameter name: :id, in: :path, type: :string, required: true
    parameter name: 'Authorization',
              in: :header,
              type: :string,
              required: true

    get 'Show assignment' do
      tags 'Assignments'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Assignment.+/)
        end
      end

      response '200', 'found assignment' do
        let(:assignment) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment.id }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly(
            'course_schedule_id', 'due_date', 'title',
            'description', 'points_possible', 'status'
          )
        end
      end

      response '401', 'unauthorized' do
        let(:assignment) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment.id }
        let(:Authorization) { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('401')
          expect(json['errors'][0]['title']).to eq('Unauthorized')
          expect(json['errors'][0]['detail']).to match(/Invalid or expired token/)
        end
      end
    end

    patch 'Update assignment' do
      tags 'Assignments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :string
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string }
        },
        required: [ 'title' ]
      }

      response '200', 'updated' do
        let(:assignment_record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment_record.id }
        let(:assignment) { { title: 'New Title' } }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          assignment_record.reload
          json = JSON.parse(response.body)
          expect(assignment_record.title).to eq('New Title')
          expect(json['data']['attributes']['title']).to eq('New Title')
          expect(json['data']['attributes'].keys).to contain_exactly(
            'course_schedule_id', 'due_date', 'title',
            'description', 'points_possible', 'status'
          )
        end
      end
      response '404', 'not found' do
        let(:id) { -99 }
        let(:assignment) { { title: 'New Title' } }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Assignment.+/)
        end
      end

      response '422', 'invalid' do
        let(:assignment_record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment_record.id }
        let(:assignment) { { title: nil } }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('422')
          expect(json['errors'][0]['title']).to eq('Unprocessable Entity')
          expect(json['errors'][0]['detail']).to match(/Title can't be blank/)
        end
      end

      response '401', 'unauthorized' do
        let(:assignment_record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment_record.id }
        let(:assignment) { { title: 'New Title' } }
        let(:Authorization) { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('401')
          expect(json['errors'][0]['title']).to eq('Unauthorized')
          expect(json['errors'][0]['detail']).to match(/Invalid or expired token/)
        end
      end
    end


    delete 'Delete assignment' do
      tags 'Assignments'

      response '204', 'deleted' do
        let(:assignment) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment.id }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do
          expect(Api::Assignment::Assignment.exists?(id)).to be(false)
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:Authorization) { auth_headers["Authorization"] }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Assignment.+/)
        end
      end
    end
  end
end
