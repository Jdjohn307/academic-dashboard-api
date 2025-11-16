require 'rails_helper'

RSpec.describe Api::Assignment::AssignmentGradeLinkController, type: :controller do
  let!(:assignment) { create(:assignment) }
  let!(:grade_record) { create(:grade_record) }

  describe "GET #index" do
    it "returns all assignment grade links" do
      create_list(:assignment_grade_link, 3, assignment: assignment, grade_record: grade_record)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns an assignment grade link by id" do
      ag_link = create(:assignment_grade_link, assignment: assignment, grade_record: grade_record)
      get :show, params: { id: ag_link.id }

      expect(response).to have_http_status(:ok)
       eq("#{ag_link.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates an assignment grade link" do
        valid_params = attributes_for(:assignment_grade_link).merge(assignment_id: assignment.id, grade_id: grade_record.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end
  end

  describe "PATCH #update" do
    it "updates an assignment grade link" do
      ag_link = create(:assignment_grade_link, assignment: assignment, grade_record: grade_record, points: 5)
      patch :update, params: { id: ag_link.id, points: 20 }

      expect(response).to have_http_status(:ok)
      expect(ag_link.reload.points).to eq(20)
    end
  end

  describe "DELETE #destroy" do
    it "deletes an assignment grade link" do
      ag_link = create(:assignment_grade_link, assignment: assignment, grade_record: grade_record)
      delete :destroy, params: { id: ag_link.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Assignment::AssignmentGradeLink.exists?(ag_link.id)).to be_falsey
    end
  end
end
