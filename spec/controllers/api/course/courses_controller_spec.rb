require 'rails_helper'

RSpec.describe Api::Course::CoursesController, type: :controller do
  # Index
  describe "GET #index" do
    it "returns all courses" do
      create_list(:course, 3)
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
    it "returns a course by id" do
      course = create(:course)
      get :show, params: { id: course.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{course.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to include('name', 'semester', 'year', 'code', 'status')
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course" do
        valid_params = attributes_for(:course)
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to include('name', 'semester', 'year', 'code', 'status')
      end
    end
    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
      it "returns errors for invalid parameters" do
        post :create, params: { name: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let!(:course) { create(:course, name: "Old Name") }
    it "updates a course" do
      patch :update, params: { id: course.id, name: "New Name" }
      expect(response).to have_http_status(:ok)
      expect(course.reload.name).to eq("New Name")
    end
    it "renders error when not found" do
      patch :update, params: { id: -99, name: "New Name" }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns errors for invalid parameters" do
      patch :update, params: { id: course.id, name: nil }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  # Destroy
  describe "DELETE #destroy" do
    let!(:course) { create(:course) }
    it "deletes a course" do
      delete :destroy, params: { id: course.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Course::Course.exists?(course.id)).to be_falsey
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
