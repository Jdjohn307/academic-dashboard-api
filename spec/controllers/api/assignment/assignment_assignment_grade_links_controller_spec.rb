require 'rails_helper'

RSpec.describe Api::Assignment::AssignmentGradeLinksController, type: :controller do
  let!(:assignment) { create(:assignment) }
  let!(:grade_record) { create(:grade_record) }

  describe "GET #index" do
    context "with records" do
      let!(:records) do
        create_list(:assignment_grade_link, 26, assignment: assignment, grade_record: grade_record)
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
    it "renders error when not found" do
      get :show, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates an assignment grade link" do
        valid_params = attributes_for(:assignment_grade_link).merge(assignment_id: assignment.id, grade_id: grade_record.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['data']['id']).to be_present
      end
    end
  end

  describe "PATCH #update" do
    it "renders error when not found" do
      patch :update, params: { id: -99, points: 10 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end

    it "updates an assignment grade link" do
      ag_link = create(:assignment_grade_link, assignment: assignment, grade_record: grade_record, points: 5)
      patch :update, params: { id: ag_link.id, points: 20 }

      expect(response).to have_http_status(:ok)
      expect(ag_link.reload.points).to eq(20)
    end
  end

  describe "DELETE #destroy" do
    it "renders error when not found" do
      delete :destroy, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      error = json['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end

    it "deletes an assignment grade link" do
      ag_link = create(:assignment_grade_link, assignment: assignment, grade_record: grade_record)
      delete :destroy, params: { id: ag_link.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Assignment::AssignmentGradeLink.exists?(ag_link.id)).to be_falsey
    end
  end
end
