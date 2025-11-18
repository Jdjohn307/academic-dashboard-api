require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleLinkController, type: :controller do
  let!(:user) { create(:user) }
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  describe "GET #index" do
    it "returns all course schedule links" do
      create_list(:course_schedule_link, 3, user: user, course_schedule: course_schedule)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a course schedule link by id" do
      link = create(:course_schedule_link, user: user, course_schedule: course_schedule)
      get :show, params: { id: link.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{link.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule link" do
        valid_params = attributes_for(:course_schedule_link).merge(course_schedule_id: course_schedule.id, user_id: user.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post :create, params: { user_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates a course schedule link" do
      link = create(:course_schedule_link, user: user, course_schedule: course_schedule)
      patch :update, params: { id: link.id, status: "inactive" }

      expect(response).to have_http_status(:ok)
      expect(link.reload.status).to eq("inactive")
    end
  end

  describe "DELETE #destroy" do
    it "deletes the course schedule link" do
      link = create(:course_schedule_link, user: user, course_schedule: course_schedule)
      delete :destroy, params: { id: link.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Course::CourseScheduleLink.exists?(link.id)).to be_falsey
    end
  end
end
