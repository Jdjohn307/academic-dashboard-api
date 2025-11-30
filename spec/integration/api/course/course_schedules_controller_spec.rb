require 'swagger_helper'

RSpec.describe 'Course Schedules API', swagger_doc: 'v1/swagger.yaml', type: :request do
  # Setup User Authentication
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let!(:role) { create(:role) }
  let!(:user_role_link) { create(:user_role_link, role: role, user: user) }

  let(:auth_headers) { auth_header_for(user) }
  let(:Authorization) { auth_headers["Authorization"] }

  before(:context) do
    @course = create(:course)
  end

  after(:context) do # TODO: Find a better way to run record creation only once
    DatabaseCleaner.clean_with(:truncation)
  end

  path '/api/course/course_schedules' do
    parameter name: 'Authorization', in: :header, type: :string, required: true

    get 'List course schedules' do
      tags 'Course Schedules'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      before(:context) do
        create_list(:course_schedule, 26, course: @course)
      end

      response '200', 'ok' do
        context 'paginated list' do
          let(:'options[page]') { nil }
          let(:'options[limit]') { nil }

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

        context 'page + limit' do
          let(:'options[page]') { 2 }
          let(:'options[limit]') { 10 }

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

        context 'invalid page fallback' do
          let(:'options[page]')  { -1 }
          let(:'options[limit]') { nil }

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

        context 'page only' do
          let(:'options[page]')  { 2 }
          let(:'options[limit]') { nil }

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

        context 'limit only' do
          let(:'options[page]')  { nil }
          let(:'options[limit]') { 5 }

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

        context 'page beyond last' do
          let(:'options[page]') { 5 }
          let(:'options[limit]') { 10 }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['data']).to eq([])
            expect(json['meta']['page']).to eq(5)
            expect(json['meta']['last']).to eq(3)
          end
        end

        context 'invalid limit' do
          let(:'options[limit]') { -5 }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.fetch('data').length).to eq(25)
            expect(json['meta']['page']).to eq(1)
          end
        end

        context 'empty list' do
          before { Api::Course::CourseSchedule.delete_all }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['data']).to eq([])
            expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
          end
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

    post 'Create course schedule' do
      tags 'Course Schedules'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          course_id: { type: :integer },
          start_date: { type: :string, format: :date },
          end_date: { type: :string, format: :date },
          schedule_json: { type: :string },
          status: { type: :string }
        },
        required: %w[name course_id start_date end_date status]
      }

      response '201', 'created' do
        let(:course_schedule) { attributes_for(:course_schedule).merge(course_id: @course.id) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'course_id', 'start_date', 'end_date', 'schedule_json', 'status')
        end
      end

      response '422', 'unprocessable' do
        context 'missing' do
          let(:course_schedule) { {} }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end

        context 'unprocessable' do
          let(:course_schedule) { { name: nil } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end
      end
    end
  end

  path '/api/course/course_schedules/{id}' do
    parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: :id, in: :path, type: :string

    get 'Show course schedule' do
      tags 'Course Schedules'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseSchedule.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:course_schedule, course: @course) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'course_id', 'start_date', 'end_date', 'schedule_json', 'status')
        end
      end
    end

    patch 'Update course schedule' do
      tags 'Course Schedules'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule, in: :body, schema: { type: :object, properties: { name: { type: :string } } }

      response '200', 'updated' do
        let!(:record) { create(:course_schedule, course: @course, name: 'Old Name') }
        let(:id) { record.id }
        let(:course_schedule) { { name: 'New Name' } }

        run_test! do |response|
          record.reload
          expect(record.name).to eq('New Name')
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'course_id', 'start_date', 'end_date', 'schedule_json', 'status')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:course_schedule) { { name: 'New Name' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseSchedule.+/)
        end
      end

      response '422', 'unprocessable' do
        let!(:record) { create(:course_schedule, course: @course, name: 'Old Name') }
        let(:id) { record.id }
        let(:course_schedule) { { name: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete course schedule' do
      tags 'Course Schedules'

      response '204', 'deleted' do
        let!(:record) { create(:course_schedule, course: @course) }
        let(:id) { record.id }

        run_test! do |response|
          expect(Api::Course::CourseSchedule.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseSchedule.+/)
        end
      end
    end
  end
end
