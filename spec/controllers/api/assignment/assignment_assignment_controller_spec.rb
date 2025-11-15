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

    it "renders correctly when no records exist" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(0)
    end
  end

  describe "GET #show" do
    it "renders error when not found" do
      get :show, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors'].length).to eq(1)
      expect(JSON.parse(response.body)['errors'][0]).to eq({"detail" => "Assignment Not Found.", "title" => "Not Found", "status" => "not_found"})
    end
    it "returns an assignment by id" do
      assignment = create(:assignment, course_schedule: course_schedule)
      get :show, params: { id: assignment.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{assignment.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
        'course_schedule_id', 'due_date', 'title', 'description', 'points_possible', 'status'
      )
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates an assignment" do
        valid_params = attributes_for(:assignment).merge(course_schedule_id: course_schedule.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
          'course_schedule_id', 'due_date', 'title', 'description', 'points_possible', 'status'
        )
      end
    end

    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: { }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns errors for invalid parameters" do
        invalid_params = attributes_for(:assignment_invalid_points).merge(course_schedule_id: course_schedule.id)
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].length).to eq(1)
        expect(JSON.parse(response.body)['errors'][0]['detail']['points_possible'][0]).to eq('is not a number')
      end

      it "returns errors for invalid parameters with complex validation" do
        invalid_params = attributes_for(:assignment_invalid_due_date).merge(course_schedule_id: course_schedule.id)
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].length).to eq(1)
        expect(JSON.parse(response.body)['errors'][0]['detail']['due_date'][0]).to include('must be less than or equal to')
      end
    end
  end

  describe "PATCH #update" do
    it "updates an assignment" do
      assignment = create(:assignment, course_schedule: course_schedule)
      patch :update, params: { id: assignment.id, title: "New Title" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
        'course_schedule_id', 'due_date', 'title', 'description', 'points_possible', 'status'
      )
      expect(assignment.reload.title).to eq("New Title")
    end
    it "renders error when not found" do
      patch :update, params: { id: -99, title: "New Title" }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors'].length).to eq(1)
      expect(JSON.parse(response.body)['errors'][0]).to eq({"detail" => "Assignment Not Found.", "title" => "Not Found", "status" => "not_found"})
    end
  end

  describe "DELETE #destroy" do
    it "deletes an assignment" do
      assignment = create(:assignment, course_schedule: course_schedule)
      delete :destroy, params: { id: assignment.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Assignment::Assignment.exists?(assignment.id)).to be_falsey
    end
    it "renders error when not found" do
      delete :destroy, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors'].length).to eq(1)
      expect(JSON.parse(response.body)['errors'][0]).to eq({"detail" => "Assignment Not Found.", "title" => "Not Found", "status" => "not_found"})
    end
  end
end
