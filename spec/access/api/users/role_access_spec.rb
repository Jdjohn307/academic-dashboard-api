
require "rails_helper"

RSpec.describe "Role Role Access", type: :request do
  let!(:auth_user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let(:auth_headers) { auth_header_for(auth_user) }

  ROLES = [
    { role_name: 'role_student', perms: { read: 403, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_teacher', perms: { read: 403, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_ta', perms: { read: 403, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_general_staff', perms: { read: 403, create: 403, update: 403, delete: 403 } }
  ]

  let!(:role) { create(:role) }

  ROLES.each do |entry|
    context "as #{entry[:role_name]}" do
      let!(:auth_role) { create(:role, entry[:role_name]) }
      let!(:auth_user_role_link) { create(:user_role_link, role: auth_role, user: auth_user) }

      it "evaluates index permissions correctly" do
        get "/api/users/roles", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates show permissions correctly" do
        get "/api/users/roles/#{role.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates create permissions correctly" do
        post "/api/users/roles", params: attributes_for(:role), headers: auth_headers
        expect(response.status).to eq(entry[:perms][:create])
      end

      it "evaluates update permissions correctly" do
        put "/api/users/roles/#{role.id}", params: { name: 'New Name' }, headers: auth_headers
        expect(response.status).to eq(entry[:perms][:update])
      end

      it "evaluates delete permissions correctly" do
        delete "/api/users/roles/#{role.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:delete])
      end
    end
  end
end
