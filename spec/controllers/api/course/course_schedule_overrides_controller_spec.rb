require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleOverridesController, type: :controller do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  # Index
  describe "GET #index" do
    it "returns all course schedule overrides" do
      create_list(:course_schedule_override, 3, course_schedule: course_schedule)
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

  # Show
  describe "GET #show" do
    it "renders error when not found" do
      get :show, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns a course schedule override by id" do
      override = create(:course_schedule_override, course_schedule: course_schedule)
      get :show, params: { id: override.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{override.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to include('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule override" do
        valid_params = attributes_for(:course_schedule_override).merge(course_schedule_id: course_schedule.id)
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to include('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
      end
    end
    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
      it "returns errors for invalid parameters" do
        post :create, params: { course_schedule_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let!(:override) { create(:course_schedule_override, course_schedule: course_schedule, notes: "Old Note") }
    it "updates a course schedule override" do
      patch :update, params: { id: override.id, notes: "New Note" }
      expect(response).to have_http_status(:ok)
      expect(override.reload.notes).to eq("New Note")
    end
    it "renders error when not found" do
      patch :update, params: { id: -99, notes: "New Note" }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns errors for invalid parameters" do
      patch :update, params: { id: override.id, notes: nil }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  # Destroy
  describe "DELETE #destroy" do
    let!(:override) { create(:course_schedule_override, course_schedule: course_schedule) }
    it "deletes a course schedule override" do
      delete :destroy, params: { id: override.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Course::CourseScheduleOverride.exists?(override.id)).to be_falsey
    end
    it "renders error when not found" do
      delete :destroy, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
  end
end
