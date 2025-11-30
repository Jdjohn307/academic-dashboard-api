require 'swagger_helper'

RSpec.describe 'Roles API', swagger_doc: 'v1/swagger.yaml', type: :request do
  # Setup User Authentication
  let!(:auth_user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let!(:auth_role) { create(:role) }
  let!(:auth_user_role_link) { create(:user_role_link, role: auth_role, user: auth_user) }

  let(:auth_headers) { auth_header_for(auth_user) }
  let(:Authorization) { auth_headers["Authorization"] }

  path '/api/users/roles' do
    parameter name: 'Authorization', in: :header, type: :string, required: true

    get 'List roles' do
      tags 'Roles'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      before(:context) do
        create_list(:role, 25)
      end

      response '200', 'ok' do
        context 'paginated list' do
          let(:'options[page]')  { nil }
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
          let(:'options[page]')  { 2 }
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
          before do # Mock returning none since we have to keep the auth_role
            allow(Api::Users::Role).to receive(:all).and_return(Api::Users::Role.none)
          end
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

    post 'Create role' do
      tags 'Roles'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :role, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          status: { type: :string }
        },
        required: %w[name status]
      }

      response '201', 'created' do
        let(:role) { attributes_for(:role) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'status')
        end
      end

      response '422', 'unprocessable' do
        context 'missing' do
          let(:role) { {} }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end

        context 'unprocessable' do
          let(:role) { { name: nil } }
          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json['errors']).to be_present
          end
        end
      end
    end
  end

  path '/api/users/roles/{id}' do
    parameter name: 'Authorization', in: :header, type: :string, required: true
    parameter name: :id, in: :path, type: :string

    get 'Show role' do
      tags 'Roles'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Role.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:role) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'status')
        end
      end
    end

    patch 'Update role' do
      tags 'Roles'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :role, in: :body, schema: { type: :object, properties: { name: { type: :string } } }

      response '200', 'updated' do
        let!(:record) { create(:role, name: 'Teacher') }
        let(:id) { record.id }
        let(:role) { { name: 'Admin' } }

        run_test! do |response|
          record.reload
          expect(record.name).to eq('Admin')
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'status')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:role) { { name: 'Admin' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Role.+/)
        end
      end

      response '422', 'unprocessable' do
        let!(:record) { create(:role, name: 'Teacher') }
        let(:id) { record.id }
        let(:role) { { name: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete role' do
      tags 'Roles'

      response '204', 'deleted' do
        let!(:record) { create(:role) }
        let(:id) { record.id }

        run_test! do |response|
          expect(Api::Users::Role.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Role.+/)
        end
      end
    end
  end
end
