require 'rails_helper'

RSpec.describe Api::Course::CourseSchedulesController, type: :controller do
  let!(:course) { create(:course) }


  describe "GET #index" do
    context "with records" do
      let!(:records) do
        create_list(:course_schedule, 26, course: course)
      end

      it "returns paginated with default pagination" do
        get :index

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(25) # Default items per page is 25
        expect(json["meta"]["page"]).to eq(1) # Default page is 1
        expect(json["meta"]["count"]).to eq(26) # Total records
        expect(json["meta"]["next"]).to eq(2) # Next page
        expect(json["meta"]["from"]).to eq(1) # From record
        expect(json["meta"]["to"]).to eq(25) # To record
        expect(json["meta"]["last"]).to eq(2) # Last page
      end

      it "returns paginated" do
        get :index, params: { options: { page: 2, limit: 10 } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(10)
        expect(json["meta"]["page"]).to eq(2)
        expect(json["meta"]["count"]).to eq(26)
        expect(json["meta"]["next"]).to eq(3)
        expect(json["meta"]["from"]).to eq(11)
        expect(json["meta"]["to"]).to eq(20)
        expect(json["meta"]["last"]).to eq(3)
      end

      it "falls back to page 1 when page is invalid" do
        get :index, params: { options: { page: -1 } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(25) # Default items per page is 25
        expect(json["meta"]["page"]).to eq(1) # Default page is 1
        expect(json["meta"]["count"]).to eq(26) # Total records
        expect(json["meta"]["next"]).to eq(2) # Next page
        expect(json["meta"]["from"]).to eq(1) # From record
        expect(json["meta"]["to"]).to eq(25) # To record
        expect(json["meta"]["last"]).to eq(2) # Last page
      end

      it "goes to correct page when only page parameter is passed in" do
        get :index, params: { options: { page: 2 } }

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['data'].length).to eq(1)
        expect(json["meta"]["page"]).to eq(2)
        expect(json["meta"]["count"]).to eq(26)
        expect(json["meta"]["next"]).to eq(nil)
        expect(json["meta"]["from"]).to eq(26)
        expect(json["meta"]["to"]).to eq(26)
        expect(json["meta"]["last"]).to eq(2)
      end

      it "paginates correctly with only limit parameter" do
        get :index, params: { options: { limit: 5 } }

        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json['data'].length).to eq(5)
        expect(json["meta"]["page"]).to eq(1)
        expect(json["meta"]["count"]).to eq(26)
        expect(json["meta"]["next"]).to eq(2)
        expect(json["meta"]["from"]).to eq(1)
        expect(json["meta"]["to"]).to eq(5)
        expect(json["meta"]["last"]).to eq(6)
      end

      it "returns empty data for page beyond last" do
        get :index, params: { options: { page: 5, limit: 10 } } # only 3 pages exist

        json = JSON.parse(response.body)
        expect(json["data"]).to eq([])
        expect(json["meta"]["page"]).to eq(5)
        expect(json["meta"]["last"]).to eq(3)
      end

      it "handles invalid limit gracefully" do
        get :index, params: { options: { limit: -5 } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(25) # Default items per page is 25
        expect(json["meta"]["page"]).to eq(1) # Default page is 1
        expect(json["meta"]["count"]).to eq(26) # Total records
        expect(json["meta"]["next"]).to eq(2) # Next page
        expect(json["meta"]["from"]).to eq(1) # From record
        expect(json["meta"]["to"]).to eq(25) # To record
        expect(json["meta"]["last"]).to eq(2) # Last page
      end
    end

    it "renders correctly when no records exist" do
      get :index
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(0)
      expect(json["meta"].keys).to include("page", "last", "from", "to", "count", "next")
    end
  end

  describe "GET #show" do
    it "returns a course schedule by id" do
      course_schedule = create(:course_schedule, course: course)
      get :show, params: { id: course_schedule.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq("#{course_schedule.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule" do
        valid_params = attributes_for(:course_schedule).merge(course_id: course.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to be_present
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
