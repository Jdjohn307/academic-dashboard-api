require 'swagger_helper'

RSpec.describe 'Course Schedule Overrides API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  path '/api/course/course_schedule_overrides' do
    get 'List course schedule overrides' do
      tags 'Course Schedule Overrides'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'paginated list' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }

        let(:'options[page]') { nil }
        let(:'options[limit]') { nil }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'page + limit' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { 10 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(10)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'invalid page fallback' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[page]') { -1 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(25)
        end
      end

      response '200', 'page only' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[page]') { 2 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(1)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'limit only' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[limit]') { 5 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(5)
        end
      end

      response '200', 'page beyond last' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[page]') { 5 }
        let(:'options[limit]') { 10 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data']).to eq([])
          expect(json['meta']['page']).to eq(5)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'invalid limit' do
        before { create_list(:course_schedule_override, 26, course_schedule: course_schedule) }
        let(:'options[limit]') { -5 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(25)
        end
      end

      response '200', 'empty list' do
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data']).to eq([])
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
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
        let(:course_schedule_override) { attributes_for(:course_schedule_override).merge(course_schedule_id: course_schedule.id) }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
        end
      end

      response '422', 'missing' do
        let(:course_schedule_override) { {} }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'invalid' do
        let(:course_schedule_override) { { course_schedule_id: nil } }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end
    end
  end

  path '/api/course/course_schedule_overrides/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show override' do
      tags 'Course Schedule Overrides'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
        end
      end

      response '200', 'found' do
        let!(:record) { create(:course_schedule_override, course_schedule: course_schedule) }
        let(:id) { record.id }

        run_test! do |res|
          json = JSON.parse(res.body)
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
        let!(:record) { create(:course_schedule_override, course_schedule: course_schedule, notes: 'Old Note') }
        let(:id) { record.id }
        let(:course_schedule_override) { { notes: 'New Note' } }

        run_test! do |res|
          record.reload
          expect(record.notes).to eq('New Note')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:course_schedule_override) { { notes: 'New Note' } }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['status']).to eq('404')
        end
      end

      response '422', 'invalid' do
        let!(:record) { create(:course_schedule_override, course_schedule: course_schedule) }
        let(:id) { record.id }
        let(:course_schedule_override) { { notes: nil } }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete override' do
      tags 'Course Schedule Overrides'

      response '204', 'deleted' do
        let!(:record) { create(:course_schedule_override, course_schedule: course_schedule) }
        let(:id) { record.id }

        run_test! do |res|
          expect(Api::Course::CourseScheduleOverride.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['status']).to eq('404')
        end
      end
    end
  end
end
