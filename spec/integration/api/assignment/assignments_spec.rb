require 'swagger_helper'

RSpec.describe 'Assignments API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  path '/api/assignment/assignments' do
    get 'List assignments (paginated)' do
      tags 'Assignments'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false

      response '200', 'assignments fetched' do
        before { create_list(:assignment, 26, course_schedule: course_schedule) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25) # default limit
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
        end
      end
    end


    post 'Create an assignment' do
      tags 'Assignments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          course_schedule_id: { type: :integer },
          due_date: { type: :string, format: :date },
          title: { type: :string },
          description: { type: :string, nullable: true },
          points_possible: { type: :integer },
          status: { type: :string }
        },
        required: %w[course_schedule_id due_date title points_possible status]
      }

      response '201', 'assignment created' do
        let(:assignment) do
          {
            course_schedule_id: course_schedule.id,
            due_date: Date.today.to_s,
            title: 'New Assignment',
            description: 'Details',
            points_possible: 50,
            status: 'active'
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        context 'missing required fields' do
          let(:assignment) { { title: '' } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end

        context 'invalid points possible' do
          let(:assignment) { { course_schedule_id: course_schedule.id, title: 'Test', points_possible: 'abc', status: 'active', due_date: Date.today.to_s } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors'][0]['detail']).to eq('Points possible is not a number')
          end
        end

        context 'invalid due date' do
          let(:assignment) { { course_schedule_id: course_schedule.id, title: 'Test', points_possible: 50, status: 'active', due_date: (course_schedule.end_date + 1.day).to_s } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors'][0]['detail']).to include('Due date must be less than or equal to')
          end
        end
      end
    end
  end

  path '/api/assignment/assignments/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retrieve an assignment' do
      tags 'Assignments'
      produces 'application/json'

      response '200', 'found' do
        let!(:record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { record.id }
        run_test!
      end

      response '404', 'not found' do
        let(:id) { -1 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0].keys).to contain_exactly('title', 'status', 'detail', 'source')
        end
      end
    end

    patch 'Update an assignment' do
      tags 'Assignments'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          points_possible: { type: :integer }
        }
      }

      response '200', 'updated' do
        let!(:record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { record.id }
        let(:assignment) { { title: 'Updated' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes']['title']).to eq('Updated')
        end
      end

      response '422', 'invalid request' do
        context 'invalid points' do
          let!(:record) { create(:assignment, course_schedule: course_schedule) }
          let(:id) { record.id }
          let(:assignment) { { points_possible: 'apples' } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors'][0]['detail']).to eq('Points possible is not a number')
          end
        end

        context 'invalid due date' do
          let!(:record) { create(:assignment, course_schedule: course_schedule) }
          let(:id) { record.id }
          let(:assignment) { { due_date: Time.zone.now() + 7.months } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors'][0]['detail']).to include('Due date must be less than or equal to')
          end
        end
      end


      response '404', 'not found' do
        let(:id) { -1 }
        let(:assignment) { { title: 'Updated' } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0].keys).to contain_exactly('title', 'status', 'detail', 'source')
        end
      end
    end

    delete 'Delete an assignment' do
      tags 'Assignments'

      response '204', 'deleted' do
        let!(:record) { create(:assignment, course_schedule: course_schedule) }
        let(:id) { record.id }
        run_test!
      end

      response '404', 'not found' do
        let(:id) { -1 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0].keys).to contain_exactly('title', 'status', 'detail', 'source')
          expect(json['errors'][0]['title']).to eq('Not Found')
        end
      end
    end
  end
end
