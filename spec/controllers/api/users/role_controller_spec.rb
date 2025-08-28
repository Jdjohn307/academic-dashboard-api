require 'rails_helper'

RSpec.describe Api::Users::RoleController, type: :controller do
  describe "GET #index" do
    it "returns all roles" do
      create_list(:role, 3)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a role by id" do
      role = create(:role)
      get :show, params: { id: role.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{role.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a role" do
        valid_params = { name: "Instructor" }
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns an error" do
        post :create, params: { apples: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end
  end

  describe "PATCH #update" do
    it "updates a role" do
      role = create(:role, name: "Teacher")
      patch :update, params: { id: role.id, name: "Admin" }

      expect(response).to have_http_status(:ok)
      expect(role.reload.name).to eq("Admin")
    end
  end

  describe "DELETE #destroy" do
    it "deletes a role" do
      role = create(:role)
      delete :destroy, params: { id: role.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Users::Role.exists?(role.id)).to be_falsey
    end
  end
end
