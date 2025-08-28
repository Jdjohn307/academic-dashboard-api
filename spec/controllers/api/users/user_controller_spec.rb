require 'rails_helper'

RSpec.describe Api::Users::UserController, type: :controller do
  describe "GET #index" do
    it "returns all users" do
      create_list(:user, 3)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a user by id" do
      user = create(:user)
      get :show, params: { id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{user.id}")
    end
  end

  describe "POST #create" do
    it "creates a new user" do
      valid_params = { name: 'Name', email: 'test@example.com', encrypted_password: 'super_secure123', created_at: Time.now, updated_at: Time.now }
      post :create, params: valid_params

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']['id']).to be_present
    end
  end

  describe "PATCH #update" do
    let!(:user) { create(:user, name: "Old Name") }
    it "updates the user" do
      patch :update, params: { id: user.id, name: "New Name" }
      expect(response).to have_http_status(:ok)
      expect(user.reload.name).to eq("New Name")
    end
  end

  describe "DELETE #destroy" do
    let!(:user) { create(:user) }
    it "deletes the user" do
      delete :destroy, params: { id: user.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Users::User.exists?(user.id)).to be_falsey
    end
  end
end