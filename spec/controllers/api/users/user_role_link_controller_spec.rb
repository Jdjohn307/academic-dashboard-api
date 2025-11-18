require 'rails_helper'

RSpec.describe Api::Users::UserRoleLinkController, type: :controller do
  let!(:user) { create(:user) }
  let!(:role) { create(:role) }

  describe "GET #index" do
    it "returns all user-role links" do
      create_list(:user_role_link, 3, user: user, role: role)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a user-role link by id" do
      link = create(:user_role_link, user: user, role: role)
      get :show, params: { id: link.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{link.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a user-role link" do
        valid_params = attributes_for(:user_role_link).merge(user_id: user.id, role_id: role.id)
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns an error" do
        post :create, params: { user_id: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end
  end

  describe "PATCH #update" do
    it "updates a user-role link" do
      link = create(:user_role_link, user: user, role: role)
      new_role = create(:role)
      patch :update, params: { id: link.id, role_id: new_role.id }

      expect(response).to have_http_status(:ok)
      expect(link.reload.role_id).to eq(new_role.id)
    end
  end

  describe "DELETE #destroy" do
    it "deletes a user-role link" do
      link = create(:user_role_link, user: user, role: role)
      delete :destroy, params: { id: link.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Users::UserRoleLink.exists?(link.id)).to be_falsey
    end
  end
end
