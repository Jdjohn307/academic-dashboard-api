require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleController, type: :controller do
  let!(:course) { create(:course) }

  describe "GET #index" do
    it "returns all course schedules" do
      create_list(:course_schedule, 3, course: course)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a course schedule by id" do
      course_schedule = create(:course_schedule, course: course)
      get :show, params: { id: course_schedule.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{course_schedule.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule" do
        valid_params = attributes_for(:course_schedule).merge(course_id: course.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post :create, params: { name: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates a course schedule" do
      course_schedule = create(:course_schedule, course: course)
      patch :update, params: { id: course_schedule.id, name: "New Name" }
      expect(response).to have_http_status(:ok)
      expect(course_schedule.reload.name).to eq("New Name")
    end
  end

  describe "DELETE #destroy" do
    it "deletes the course schedule" do
      course_schedule = create(:course_schedule, course: course)
      delete :destroy, params: { id: course_schedule.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Course::CourseSchedule.exists?(course_schedule.id)).to be_falsey
    end
  end
end
