require 'swagger_helper'

RSpec.describe 'Courses API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/api/course/courses' do
    get 'List courses' do
      tags 'Courses'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'paginated list' do
        before { create_list(:course, 26) }

        let(:'options[page]') { nil }
        let(:'options[limit]') { nil }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25)
          expect(json['meta']['page']).to eq(1)
          expect(json['meta']['count']).to eq(26)
        end
      end

      response '200', 'page + limit' do
        before { create_list(:course, 26) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { 10 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(10)
          expect(json['meta']['page']).to eq(2)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'invalid page falls back' do
        before { create_list(:course, 26) }
        let(:'options[page]') { -1 }
        let(:'options[limit]') { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'page only' do
        before { create_list(:course, 26) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(1)
          expect(json['meta']['page']).to eq(2)
        end
      end

      response '200', 'limit only' do
        before { create_list(:course, 26) }
        let(:'options[page]') { nil }
        let(:'options[limit]') { 5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(5)
          expect(json['meta']['last']).to eq(6)
        end
      end

      response '200', 'page beyond last' do
        before { create_list(:course, 26) }
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
        before { create_list(:course, 26) }
        let(:'options[page]') { nil }
        let(:'options[limit]') { -5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data'].length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'empty list' do
        let(:'options[page]') { nil }
        let(:'options[limit]') { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta'].keys).to include('page', 'last', 'from', 'to', 'count', 'next')
        end
      end
    end

    post 'Create course' do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          semester: { type: :string },
          year: { type: :integer },
          code: { type: :string },
          status: { type: :string }
        },
        required: %w[name semester year code status]
      }

      response '201', 'created' do
        let(:course) { attributes_for(:course) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'semester', 'year', 'code', 'status')
        end
      end

      response '422', 'missing' do
        let(:course) { {} }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'invalid' do
        let(:course) { { name: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end
  end

  path '/api/course/courses/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show course' do
      tags 'Courses'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Course.+/)
        end
      end

      response '200', 'found' do
        let!(:record) { create(:course) }
        let(:id) { record.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'semester', 'year', 'code', 'status')
        end
      end
    end

    patch 'Update course' do
      tags 'Courses'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :course, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response '200', 'updated' do
        let!(:record) { create(:course, name: 'Old Name') }
        let(:id) { record.id }
        let(:course) { { name: 'New Name' } }

        run_test! do |response|
          record.reload
          expect(record.name).to eq('New Name')
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(record.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('name', 'semester', 'year', 'code', 'status')
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }
        let(:course) { { name: 'New Name' } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Course.+/)
        end
      end

      response '422', 'invalid' do
        let!(:record) { create(:course, name: 'Old Name') }
        let(:id) { record.id }
        let(:course) { { name: nil } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    delete 'Delete course' do
      tags 'Courses'

      response '204', 'deleted' do
        let!(:record) { create(:course) }
        let(:id) { record.id }

        run_test! do |response|
          expect(Api::Course::Course.exists?(id)).to be_falsey
        end
      end

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+Course.+/)
        end
      end
    end
  end
end
