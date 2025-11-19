require 'rails_helper'

RSpec.describe Api::Users::UsersController, type: :controller do
  # Index
  describe "GET #index" do
    it "returns all users" do
      create_list(:user, 3)
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
      expect(error['detail']).to match(/Couldn't find .+User.+/)
    end

    it "returns a user by id" do
      user = create(:user)
      get :show, params: { id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{user.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
        'name', 'email', 'encrypted_password', 'status'
      )
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new user" do
        valid_params = attributes_for(:user)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
          'name', 'email', 'encrypted_password', 'status'
        )
      end
    end

    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end

      it "returns errors for invalid parameters" do
        invalid_params = attributes_for(:user, :user_invalid_status)
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let!(:user) { create(:user, name: "Old Name") }

    it "updates the user" do
      patch :update, params: { id: user.id, name: "New Name" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['attributes'].keys).to contain_exactly(
        'name', 'email', 'encrypted_password', 'status'
      )
      expect(user.reload.name).to eq("New Name")
    end

    it "renders error when not found" do
      patch :update, params: { id: -99, name: "New Name" }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/Couldn't find .+User.+/)
    end

    it "returns errors for invalid parameters" do
      patch :update, params: { id: user.id, status: "banana" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end
  end

  # Destroy
  describe "DELETE #destroy" do
    let!(:user) { create(:user) }

    it "deletes the user" do
      delete :destroy, params: { id: user.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Users::User.exists?(user.id)).to be_falsey
    end

    it "renders error when not found" do
      delete :destroy, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/Couldn't find .+User.+/)
    end
  end
end
