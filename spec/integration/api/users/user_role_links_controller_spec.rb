require 'swagger_helper'

RSpec.describe 'User Role Links API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:user) { create(:user) }
  let!(:role) { create(:role) }

  path '/api/users/user_role_links' do
    get 'List user-role links' do
      tags 'User Role Links'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'paginated list' do
        before { create_list(:user_role_link, 26, user: user, role: role) }

        let(:'options[page]') { nil }
        let(:'options[limit]') { nil }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'page + limit' do
        before { create_list(:user_role_link, 26, user: user, role: role) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { 10 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(10)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'invalid page fallback' do
        before { create_list(:user_role_link, 26, user: user, role: role) }
        let(:'options[page]') { -1 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(25)
        end
      end

      response '200', 'page only' do
        before { create_list(:user_role_link, 26, user: user, role: role) }
        let(:'options[page]') { 2 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(1)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'limit only' do
        before { create_list(:user_role_link, 26, user: user, role: role) }
        let(:'options[limit]') { 5 }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data'].length).to eq(5)
        end
      end

      response '200', 'page beyond last' do
        before { create_list(:user_role_link, 26, user: user, role: role) }
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
        before { create_list(:user_role_link, 26, user: user, role: role) }
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

    post 'Create user-role link' do
      tags 'User Role Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_role_link, in: :body, schema: {
        type: :object,
        properties: {
          user_id: { type: :integer },
          role_id: { type: :integer },
          status: { type: :string }
        },
        required: %w[user_id role_id]
      }

      response '201', 'created' do
        let(:user_role_link) { attributes_for(:user_role_link).merge(user_id: user.id, role_id: role.id) }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data']['attributes'].keys).to contain_exactly('user_id', 'role_id', 'status')
        end
      end

      response '422', 'missing' do
        let(:user_role_link) { {} }
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'invalid' do
        let(:user_role_link) { { user_id: nil } }
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end
    end
  end

  path '/api/users/user_role_links/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show user-role link' do
      tags 'User Role Links'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
        end
      end

      response '200', 'found' do
        let!(:record) { create(:user_role_link, user: user, role: role) }
        let(:id) { record.id }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('user_id', 'role_id', 'status')
        end
      end
    end

    patch 'Update user-role link' do
      tags 'User Role Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user_role_link, in: :body, schema: {
        type: :object,
        properties: {
          role_id: { type: :integer },
          user_id: { type: :integer },
          status: { type: :string }
        }
      }

      response '200', 'updated' do
        let!(:link) { create(:user_role_link, user: user, role: role) }
        let(:id) { link.id }
        let(:user_role_link) { { role_id: create(:role).id } }

        run_test! do |_res|
          link.reload
          expect(link.role_id).to_not eq(role.id)
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:user_role_link) { { role_id: role.id } }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
        end
      end

      response '422', 'invalid' do
        let!(:link) { create(:user_role_link, user: user, role: role) }
        let(:id) { link.id }
        let(:user_role_link) { { user_id: nil } }

        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete user-role link' do
      tags 'User Role Links'

      response '204', 'deleted' do
        let!(:link) { create(:user_role_link, user: user, role: role) }
        let(:id) { link.id }

        run_test! do |_res|
          expect(Api::Users::UserRoleLink.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |res|
          json = JSON.parse(res.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
        end
      end
    end
  end
end
