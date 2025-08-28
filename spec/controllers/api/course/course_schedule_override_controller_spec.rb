require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleOverrideController, type: :controller do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  describe "GET #index" do
    it "returns all overrides" do
      create_list(:course_schedule_override, 3, course_schedule: course_schedule)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns an override by id" do
      override = create(:course_schedule_override, course_schedule: course_schedule)
      get :show, params: { id: override.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{override.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates an override" do
        valid_params = { course_schedule_id: course_schedule.id, override_date: Time.now, schedule_json: { friday: ["16:00", "18:00"] } }
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post :create, params: { course_schedule_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    it "updates an override" do
      override = create(:course_schedule_override, course_schedule: course_schedule)
      patch :update, params: { id: override.id, notes: "Updated note" }

      expect(response).to have_http_status(:ok)
      expect(override.reload.notes).to eq("Updated note")
    end
  end

  describe "DELETE #destroy" do
    it "deletes an override" do
      override = create(:course_schedule_override, course_schedule: course_schedule)
      delete :destroy, params: { id: override.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Course::CourseScheduleOverride.exists?(override.id)).to be_falsey
    end
  end
end
