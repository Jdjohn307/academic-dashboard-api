require 'swagger_helper'

RSpec.describe 'Assignment Grade Links API', swagger_doc: 'v1/swagger.yaml', type: :request do
  let!(:assignment) { create(:assignment) }
  let!(:grade_record) { create(:grade_record) }

  path '/api/assignment/assignment_grade_links' do
    get 'List assignment grade links' do
      tags 'Assignment Grade Links'
      produces 'application/json'
      parameter name: :'options[page]', in: :query, type: :integer, required: false
      parameter name: :'options[limit]', in: :query, type: :integer, required: false

      response '200', 'paginated list' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }

        # default pagination
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

      response '200', 'page + limit' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
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

      response '200', 'invalid page falls back' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
        let(:'options[page]') { -1 }
        let(:'options[limit]') { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
          expect(json['meta']['page']).to eq(1)
        end
      end

      response '200', 'page only' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
        let(:'options[page]') { 2 }
        let(:'options[limit]') { nil }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(1)
          expect(json['meta']['page']).to eq(2)
          expect(json['meta']['from']).to eq(26)
          expect(json['meta']['to']).to eq(26)
          expect(json['meta']['next']).to be_nil
          expect(json['meta']['last']).to eq(2)
        end
      end

      response '200', 'limit only' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
        let(:'options[page]') { nil }
        let(:'options[limit]') { 5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(5)
          expect(json['meta']['page']).to eq(1)
          expect(json['meta']['last']).to eq(6)
        end
      end

      response '200', 'page beyond last' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
        let(:'options[page]') { 5 }
        let(:'options[limit]') { 10 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']).to eq([])
          expect(json['meta']['page']).to eq(5)
          expect(json['meta']['last']).to eq(3)
        end
      end

      response '200', 'invalid limit gracefully' do
        before { create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record) }
        let(:'options[page]') { nil }
        let(:'options[limit]') { -5 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json.fetch('data').length).to eq(25)
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

    post 'Create assignment grade link' do
      tags 'Assignment Grade Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :assignment_grade_link, in: :body, schema: {
        type: :object,
        properties: {
          assignment_id: { type: :integer },
          grade_id: { type: :integer },
          points: { type: :number },
          notes: { type: :string }
        },
        required: %w[assignment_id grade_id]
      }

      response '201', 'created' do
        let(:assignment_grade_link) { attributes_for(:assignment_grade_link).merge(assignment_id: assignment.id, grade_id: grade_record.id) }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['attributes'].keys).to contain_exactly('assignment_id', 'feedback', 'grade', 'grade_id', 'graded_at', 'points', 'submitted_at', 'status')
        end
      end

      response '422', 'missing' do
        let(:assignment_grade_link) { {} }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end

      response '422', 'invalid' do
        let(:assignment_grade_link) { {} }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end
  end

  path '/api/assignment/assignment_grade_links/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Show assignment grade link' do
      tags 'Assignment Grade Links'
      produces 'application/json'

      response '404', 'not found' do
        let(:id) { -99 }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+AssignmentGradeLink.+/)
        end
      end

      response '200', 'found' do
        let!(:ag_link) { create(:assignment_grade_link, assignment: assignment, grade_record: grade_record, points: 5) }
        let(:id) { ag_link.id }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(ag_link.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('assignment_id', 'feedback', 'grade', 'grade_id', 'graded_at', 'points', 'submitted_at', 'status')
        end
      end
    end

    patch 'Update assignment grade link' do
      tags 'Assignment Grade Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :assignment_grade_link, in: :body, schema: {
        type: :object,
        properties: {
          points: { type: :number }
        }
      }

      response '404', 'not found' do
        let(:id) { -99 }
        let(:assignment_grade_link) { { points: 10 } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+AssignmentGradeLink.+/)
        end
      end

      response '200', 'updated' do
        let!(:ag_link) { create(:assignment_grade_link, assignment: assignment, grade_record: grade_record, points: 5) }
        let(:id) { ag_link.id }
        let(:assignment_grade_link) { { points: 20 } }

        run_test! do |response|
          ag_link.reload
          expect(ag_link.points).to eq(20)
          json = JSON.parse(response.body)
          expect(json['data']['id']).to eq(ag_link.id.to_s)
          expect(json['data']['attributes'].keys).to contain_exactly('assignment_id', 'feedback', 'grade', 'grade_id', 'graded_at', 'points', 'submitted_at', 'status')
        end
      end
    end

    delete 'Delete assignment grade link' do
      tags 'Assignment Grade Links'

      response '404', 'not found' do
        let(:id) { -99 }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json['errors'][0]['status']).to eq('404')
          expect(json['errors'][0]['title']).to eq('Not Found')
          expect(json['errors'][0]['detail']).to match(/Couldn't find .+AssignmentGradeLink.+/)
        end
      end

      response '204', 'deleted' do
        let!(:ag_link) { create(:assignment_grade_link, assignment: assignment, grade_record: grade_record) }
        let(:id) { ag_link.id }

        run_test! do |response|
          expect(Api::Assignment::AssignmentGradeLink.exists?(id)).to be_falsey
        end
      end
    end
  end
end
