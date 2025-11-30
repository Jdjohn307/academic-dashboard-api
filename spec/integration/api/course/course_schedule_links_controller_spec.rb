require 'swagger_helper'

RSpec.describe 'Course Schedule Links API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:user) { create(:user) }
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  path '/api/course/course_schedule_links' do
    get 'List course schedule links' do
      tags 'Course Schedule Links'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'paginated list' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }

        let(:'options[page]') { nil }
        let(:'options[limit]') { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'page + limit' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { 10 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(10)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'invalid page fallback' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[page]') { -1 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
        end
      end

      response '200', 'page only' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[page]') { 2 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(1)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'limit only' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[limit]') { 5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(5)
        end
      end

      response '200', 'page beyond last' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[page]') { 5 }
        let(:'options[limit]') { 10 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta']['page']).to eq(5)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'invalid limit' do
        before { create_list(:course_schedule_link, 26, user: user, course_schedule: course_schedule) }
        let(:'options[limit]') { -5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
        end
      end

      response '200', 'empty list' do
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
        end
      end
    end

    post 'Create course schedule link' do
      tags 'Course Schedule Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule_link, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          course_schedule_id: { type: :integer },
          status: { type: :string }
        },
        required: %w[user_id course_schedule_id]
      }

      response '201', 'created' do
        let(:course_schedule_link) { attributes_for(:course_schedule_link).merge(user_id: user.id, course_schedule_id: course_schedule.id) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('user_id', 'course_schedule_id', 'status')
        end
      end

      response '422', 'missing' do
        let(:course_schedule_link) { {} }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'unprocessable' do
        let(:course_schedule_link) { { user_id: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end
  end

  path '/api/course/course_schedule_links/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show course schedule link' do
      tags 'Course Schedule Links'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleLink.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:course_schedule_link, user: user, course_schedule: course_schedule) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('user_id', 'course_schedule_id', 'status')
        end
      end
    end

    patch 'Update course schedule link' do
      tags 'Course Schedule Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course_schedule_link, in: :body, schema: { type: :object, properties: { status: { type: :string }, user_id: { type: :integer } } }

      response '200', 'updated' do
        let!(:link) { create(:course_schedule_link, user: user, course_schedule: course_schedule, status: 'active') }
        let(:id) { link.id }
        let(:course_schedule_link) { { status: 'inactive' } }

        run_test! do |response|
          link.reload
          expect(link.status).to eq('inactive')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:course_schedule_link) { { status: 'inactive' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleLink.+/)
        end
      end

      response '422', 'unprocessable' do
        let!(:link) { create(:course_schedule_link, user: user, course_schedule: course_schedule) }
        let(:id) { link.id }
        let(:course_schedule_link) { { user_id: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete course schedule link' do
      tags 'Course Schedule Links'

      response '204', 'deleted' do
        let!(:link) { create(:course_schedule_link, user: user, course_schedule: course_schedule) }
        let(:id) { link.id }

        run_test! do |response|
          expect(Api::Course::CourseScheduleLink.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+CourseScheduleLink.+/)
        end
      end
    end
  end
end
