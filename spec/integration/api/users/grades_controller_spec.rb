require 'swagger_helper'

RSpec.describe 'Grades API', swagger_doc: 'v1/swagger.yaml', type: :request do
  # Setup User Authentication
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let!(:role) { create(:role) }
  let!(:user_role_link) { create(:user_role_link, role: role, user: user) }

  let(:auth_headers) { auth_header_for(user) }
  let(:Authorization) { auth_headers["Authorization"] }

  before(:context) do
    @user_record = create(:user)
    @course = create(:course)
  end

  after(:context) do # TODO: Find a better way to run record creation only once
    DatabaseCleaner.clean_with(:truncation)
  end

  path '/api/users/grades' do
    parameter name: 'Authorization', in: :header, type: :string, required: true

    get 'List grades' do
      tags 'Grades'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      before(:context) do
        create_list(:grade_record, 26, user: @user_record, course: @course)
      end

      response '200', 'ok' do
        response '200', 'paginated list' do
          let(:'options[page]')  { nil }
          let(:'options[limit]') { nil }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.fetch('data').length).to eq(25)
            expect(json['meta']['page']).to eq(1)
          end
        end

        response '200', 'page + limit' do
          let(:'options[page]') { 2 }
          let(:'options[limit]') { 10 }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.fetch('data').length).to eq(10)
            expect(json['meta']['page']).to eq(2)
          end
        end

        response '200', 'invalid page fallback' do
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

        response '200', 'page only' do
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

        response '200', 'limit only' do
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

        response '200', 'page beyond last' do
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
          let(:'options[limit]') { -5 }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json.fetch('data').length).to eq(25)
          end
        end

        response '200', 'empty list' do
          before { Api::Users::Grade.delete_all }
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

    post 'Create grade' do
      tags 'Grades'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :grade_record, in: :body, schema: {
        type: :object,
        properties: {
          final_grade: { type: :number },
          comments: { type: :string },
          status: { type: :string },
          course_id: { type: :integer },
          user_id: { type: :integer }
        },
        required: %w[final_grade course_id user_id status]
      }

      response '201', 'created' do
        let(:grade_record) { attributes_for(:grade_record).merge(user_id: @user_record.id, course_id: @course.id) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('final_grade', 'comments', 'status', 'course_id', 'user_id')
        end
      end

      response '422', 'unprocessable' do
        context 'missing' do
          let(:grade_record) { {} }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end

        context 'unprocessable' do
          let(:grade_record) { { user_id: nil, course_id: nil } }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end
      end
    end
  end

  path '/api/users/grades/{id}' do
    parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: :id, in: :path, type: :string

    get 'Show grade' do
      tags 'Grades'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Grade.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:grade_record, user: @user_record, course: @course) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('final_grade', 'comments', 'status', 'course_id', 'user_id')
        end
      end
    end

    patch 'Update grade' do
      tags 'Grades'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :grade_record, in: :body, schema: {
        type: :object,
        properties: {
          final_grade: { type: :number }
        }
      }

      response '200', 'updated' do
        let!(:record) { create(:grade_record, user: @user_record, course: @course, final_grade: 85.0) }
        let(:id) { record.id }
        let(:grade_record) { { final_grade: 90.5 } }

        run_test! do |response|
          record.reload
          expect(record.final_grade).to eq(90.5)
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('final_grade', 'comments', 'status', 'course_id', 'user_id')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:grade_record) { { final_grade: 90.5 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Grade.+/)
        end
      end

      response '422', 'unprocessable' do
        let!(:record) { create(:grade_record, user: @user_record, course: @course, final_grade: 85.0) }
        let(:id) { record.id }
        let(:grade_record) { { final_grade: -1 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['detail']).to eq('Final grade must be greater than or equal to 0')
        end
      end
    end

    delete 'Delete grade' do
      tags 'Grades'

      response '204', 'deleted' do
        let!(:record) { create(:grade_record, user: @user_record, course: @course) }
        let(:id) { record.id }

        run_test! do |response|
          expect(Api::Users::Grade.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Grade.+/)
        end
      end
    end
  end
end
