require 'rails_helper'

RSpec.describe Api::Assignment::AssignmentController, type: :controller do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  describe "GET #index" do
    it "returns all assignments" do
      create_list(:assignment, 3, course_schedule: course_schedule)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns an assignment by id" do
      assignment = create(:assignment, course_schedule: course_schedule)
      get :show, params: { id: assignment.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{assignment.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates an assignment" do
        valid_params = attributes_for(:assignment).merge(course_schedule_id: course_schedule.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post :create, params: { title: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates an assignment" do
      assignment = create(:assignment, course_schedule: course_schedule)
      patch :update, params: { id: assignment.id, title: "New Title" }

      expect(response).to have_http_status(:ok)
      expect(assignment.reload.title).to eq("New Title")
    end
  end

  describe "DELETE #destroy" do
    it "deletes an assignment" do
      assignment = create(:assignment, course_schedule: course_schedule)
      delete :destroy, params: { id: assignment.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Assignment::Assignment.exists?(assignment.id)).to be_falsey
    end
  end
end
