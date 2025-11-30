
require "rails_helper"

RSpec.describe "User Role Link Role Access", type: :request do
  let!(:auth_user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let(:auth_headers) { auth_header_for(auth_user) }

  ROLES = [
    { role_name: 'role_student', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_teacher', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_ta', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_general_staff', perms: { read: 200, create: 403, update: 403, delete: 403 } }
  ]

  let!(:user) { create(:user) }
  let!(:role) { create(:role) }
  let!(:user_role_link) { create(:user_role_link, user: user, role: role) }

  ROLES.each do |entry|
    context "as #{entry[:role_name]}" do
      let!(:auth_role) { create(:role, entry[:role_name]) }
      let!(:auth_user_role_link) { create(:user_role_link, role: auth_role, user: auth_user) }

      it "evaluates index permissions correctly" do
        get "/api/users/user_role_links", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates show permissions correctly" do
        get "/api/users/user_role_links/#{user_role_link.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates create permissions correctly" do
        post "/api/users/user_role_links", params: attributes_for(:user_role_link).merge(role_id: role.id, user_id: user.id), headers: auth_headers
        expect(response.status).to eq(entry[:perms][:create])
      end

      it "evaluates update permissions correctly" do
        put "/api/users/user_role_links/#{user_role_link.id}", params: { title: 'New Title' }, headers: auth_headers
        expect(response.status).to eq(entry[:perms][:update])
      end

      it "evaluates delete permissions correctly" do
        delete "/api/users/user_role_links/#{user_role_link.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:delete])
      end
    end
  end
end
