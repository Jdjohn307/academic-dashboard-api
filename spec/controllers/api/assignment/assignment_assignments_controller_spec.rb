require 'rails_helper'

RSpec.describe Api::Assignment::AssignmentsController, type: :controller do
  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }

  describe "GET #index" do
    context "with records" do
      before do
        create_list(:assignment, 40, course_schedule: course_schedule)
      end

      it "returns paginated assignments with default pagination" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["data"].length).to eq(25) # Default items per page is 25
        expect(JSON.parse(response.body)["meta"]["page"]).to eq(1) # Default page is 1
        expect(JSON.parse(response.body)["meta"]["count"]).to eq(40) # Total records
        expect(JSON.parse(response.body)["meta"]["next"]).to eq(2) # Next page
        expect(JSON.parse(response.body)["meta"]["from"]).to eq(1) # From record
        expect(JSON.parse(response.body)["meta"]["to"]).to eq(25) # To record
        expect(JSON.parse(response.body)["meta"]["last"]).to eq(2) # Last page
      end

      it "returns paginated assignments" do
        get :index, params: { options: { page: 2, limit: 10 } }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["data"].length).to eq(10)
        expect(JSON.parse(response.body)["meta"]["page"]).to eq(2)
        expect(JSON.parse(response.body)["meta"]["count"]).to eq(40)
        expect(JSON.parse(response.body)["meta"]["next"]).to eq(3)
        expect(JSON.parse(response.body)["meta"]["from"]).to eq(11)
        expect(JSON.parse(response.body)["meta"]["to"]).to eq(20)
        expect(JSON.parse(response.body)["meta"]["last"]).to eq(4)
      end
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
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
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
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns errors for invalid parameters" do
        invalid_params = attributes_for(:assignment, :assignment_invalid_points).merge(course_schedule_id: course_schedule.id)
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].length).to eq(1)
        expect(JSON.parse(response.body)['errors'][0]['detail']).to eq('Points possible is not a number')
      end

      it "returns errors for invalid parameters with complex validation" do
        invalid_params = attributes_for(:assignment, :assignment_invalid_due_date).merge(course_schedule_id: course_schedule.id)
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].length).to eq(1)
        expect(JSON.parse(response.body)['errors'][0]['detail']).to include('Due date must be less than or equal to')
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
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
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
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
  end
end
