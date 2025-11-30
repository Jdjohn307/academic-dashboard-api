require 'swagger_helper'

RSpec.describe 'Course Schedule Overrides API', swagger_doc: 'v1/swagger.yaml', type: :request do
  # Setup User Authentication
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let!(:role) { create(:role) }
  let!(:user_role_link) { create(:user_role_link, role: role, user: user) }

  let(:auth_headers) { auth_header_for(user) }
  let(:Authorization) { auth_headers["Authorization"] }

  before(:context) do
    @course = create(:course)
    @course_schedule = create(:course_schedule, course: @course)
  end

  after(:context) do # TODO: Find a better way to run record creation only once
    DatabaseCleaner.clean_with(:truncation)
  end

  path '/api/course/course_schedule_overrides' do
    parameter name: 'Authorization', in: :header, type: :string, required: true

    get 'List course schedule overrides' do
      tags 'Course Schedule Overrides'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      before(:context) do
        create_list(:course_schedule_override, 26, course_schedule: @course_schedule)
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
          end
        end

        context 'empty list' do
          before { Api::Course::CourseScheduleOverride.delete_all }
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

    post 'Create override' do
      tags 'Course Schedule Overrides'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule_override, in: :body, schema: {
        type: :object,
        properties: {
          course_schedule_id: { type: :integer },
          override_date: { type: :string, format: :date },
          notes: { type: :string },
          schedule_json: { type: :string },
          status: { type: :string }
        },
        required: %w[course_schedule_id override_date status]
      }

      response '201', 'created' do
        let(:course_schedule_override) { attributes_for(:course_schedule_override).merge(course_schedule_id: @course_schedule.id) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
        end
      end

      response '422', 'unprocessable' do
        context 'missing' do
          let(:course_schedule_override) { {} }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end

        context 'unprocessable' do
          let(:course_schedule_override) { { course_schedule_id: nil } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end
      end
    end
  end

  path '/api/course/course_schedule_overrides/{id}' do
    parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: :id, in: :path, type: :string

    get 'Show override' do
      tags 'Course Schedule Overrides'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleOverride.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:course_schedule_override, course_schedule: @course_schedule) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
        end
      end
    end

    patch 'Update override' do
      tags 'Course Schedule Overrides'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule_override, in: :body, schema: { type: :object, properties: { notes: { type: :string } } }

      response '200', 'updated' do
        let!(:record) { create(:course_schedule_override, course_schedule: @course_schedule, notes: 'Old Note') }
        let(:id) { record.id }
        let(:course_schedule_override) { { notes: 'New Note' } }

        run_test! do |response|
          record.reload
          expect(record.notes).to eq('New Note')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:course_schedule_override) { { notes: 'New Note' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleOverride.+/)
        end
      end

      response '422', 'unprocessable' do
        let!(:record) { create(:course_schedule_override, course_schedule: @course_schedule) }
        let(:id) { record.id }
        let(:course_schedule_override) { { notes: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete override' do
      tags 'Course Schedule Overrides'

      response '204', 'deleted' do
        let!(:record) { create(:course_schedule_override, course_schedule: @course_schedule) }
        let(:id) { record.id }

        run_test! do |response|
          expect(Api::Course::CourseScheduleOverride.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleOverride.+/)
        end
      end
    end
  end
end
