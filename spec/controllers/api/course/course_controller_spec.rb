require 'rails_helper'

RSpec.describe Api::Course::CourseController, type: :controller do
  describe "GET #index" do
    it "returns all courses" do
      create_list(:course, 3)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a course by id" do
      course = create(:course)
      get :show, params: { id: course.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{course.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new course" do
        valid_params = attributes_for(:course)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post :create, params: { name: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
        expect(JSON.parse(response.body)['error'][0]['title']).to eq('Invalid Data')
      end
    end
  end

  describe "PATCH #update" do
    let!(:course) { create(:course, name: "Old Name") }

    context "with valid id and params" do
      it "updates the course" do
        patch :update, params: { id: course.id, name: "New Name" }
        expect(response).to have_http_status(:ok)
        expect(course.reload.name).to eq("New Name")
      end
    end

    context "with invalid id" do
      it "returns not found" do
        patch :update, params: { id: 999999, name: "New Name" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:course) { create(:course) }

    context "when course exists" do
      it "deletes the course" do
        delete :destroy, params: { id: course.id }
        expect(response).to have_http_status(:no_content)
        expect(Api::Course::Course.exists?(course.id)).to be_falsey
      end
    end

    context "when course does not exist" do
      it "returns not found" do
        delete :destroy, params: { id: 123456 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end