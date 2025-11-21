require 'rails_helper'

RSpec.describe Api::Course::CourseScheduleOverridesController, type: :controller do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  # Index
  describe "GET #index" do
    context "with records" do
      let!(:records) do
        create_list(:course_schedule_override, 26, course_schedule: course_schedule)
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

  # Show
  describe "GET #show" do
    it "renders error when not found" do
      get :show, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns a course schedule override by id" do
      override = create(:course_schedule_override, course_schedule: course_schedule)
      get :show, params: { id: override.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq("#{override.id}")
      expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course schedule override" do
        valid_params = attributes_for(:course_schedule_override).merge(course_schedule_id: course_schedule.id)
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['attributes'].keys).to contain_exactly('course_schedule_id', 'override_date', 'notes', 'status', 'schedule_json')
      end
    end

    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
      it "returns errors for invalid parameters" do
        post :create, params: { course_schedule_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
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
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns errors for invalid parameters" do
      patch :update, params: { id: override.id, notes: nil }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
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
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
  end
end
