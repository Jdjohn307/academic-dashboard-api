require 'swagger_helper'

RSpec.describe 'Assignments API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  path '/api/assignment/assignments' do
    get 'List assignments' do
      tags 'Assignments'
      produces 'application/json'

      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'assignments listed default pagination' do
        let(:'options[page]')  { nil }
        let(:'options[limit]') { nil }

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25)
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

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(10)
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

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25)
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

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json['data'].length).to eq(1)
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

        before do
          create_list(:assignment, 26, course_schedule: course_schedule)
        end

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(response.status).to eq(200)
          expect(json['data'].length).to eq(5)
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

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
        end
      end
    end
  end

  # =========================================================
  # SHOW / CREATE / UPDATE / DELETE
  # =========================================================

  path '/api/assignment/assignments/{id}' do
    parameter name: :id, in: :path, type: :string, required: true

    get 'Show assignment' do
      tags 'Assignments'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          err = json['errors'][0]
          expect(err['title']).to eq('Not Found')
          expect(err['status']).to eq('404')
        end
      end

      response '200', 'found assignment' do
        let(:assignment) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly(
            'course_schedule_id', 'due_date', 'title',
            'description', 'points_possible', 'status'
          )
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

        run_test! do |response|
          assignment_record.reload
          json = JSON.parse(response.body)
          expect(assignment_record.title).to eq('New Title')
          expect(json['data']['attributes']['title']).to eq('New Title')
        end
      end
    end


    delete 'Delete assignment' do
      tags 'Assignments'

      response '204', 'deleted' do
        let(:assignment) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { assignment.id }

        run_test! do
          expect(Api::Assignment::Assignment.exists?(id)).to be(false)
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
        end
      end
    end
  end
end
