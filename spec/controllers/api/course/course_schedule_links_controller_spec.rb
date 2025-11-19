require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleLinksController, type: :controller do
  let!(:user) { create(:user) }
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  # Index
  describe "GET #index" do
    it "returns all course schedule links" do
      create_list(:course_schedule_link, 3, user: user, course_schedule: course_schedule)
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
    it "returns a course schedule link by id" do
      link = create(:course_schedule_link, user: user, course_schedule: course_schedule)
      get :show, params: { id: link.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{link.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to include('user_id', 'course_schedule_id', 'status')
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule link" do
        valid_params = attributes_for(:course_schedule_link).merge(course_schedule_id: course_schedule.id, user_id: user.id)
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to include('user_id', 'course_schedule_id', 'status')
      end
    end
    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
      it "returns errors for invalid parameters" do
        post :create, params: { user_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let!(:link) { create(:course_schedule_link, user: user, course_schedule: course_schedule) }
    it "updates a course schedule link" do
      patch :update, params: { id: link.id, status: "inactive" }
      expect(response).to have_http_status(:ok)
      expect(link.reload.status).to eq("inactive")
    end
    it "renders error when not found" do
      patch :update, params: { id: -99, status: "inactive" }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns errors for invalid parameters" do
      patch :update, params: { id: link.id, user_id: nil }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  # Destroy
  describe "DELETE #destroy" do
    let!(:link) { create(:course_schedule_link, user: user, course_schedule: course_schedule) }
    it "deletes a course schedule link" do
      delete :destroy, params: { id: link.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Course::CourseScheduleLink.exists?(link.id)).to be_falsey
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
