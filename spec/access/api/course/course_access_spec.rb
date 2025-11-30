
require "rails_helper"

RSpec.describe "Courses Role Access", type: :request do
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let(:auth_headers) { auth_header_for(user) }

  ROLES = [
    { role_name: 'role_student', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_teacher', perms: { read: 200, create: 403, update: 200, delete: 403 } },
    { role_name: 'role_ta', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_general_staff', perms: { read: 200, create: 201, update: 200, delete: 204 } }
  ]

  let!(:course) { create(:course) }

  ROLES.each do |entry|
    context "as #{entry[:role_name]}" do
      let!(:role) { create(:role, entry[:role_name]) }
      let!(:user_role_link) { create(:user_role_link, role: role, user: user) }

      it "evaluates index permissions correctly" do
        get "/api/course/courses", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates show permissions correctly" do
        get "/api/course/courses/#{course.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates create permissions correctly" do
        post "/api/course/courses", params: attributes_for(:course), headers: auth_headers
        expect(response.status).to eq(entry[:perms][:create])
      end

      it "evaluates update permissions correctly" do
        put "/api/course/courses/#{course.id}", params: { title: 'New Title' }, headers: auth_headers
        expect(response.status).to eq(entry[:perms][:update])
      end

      it "evaluates delete permissions correctly" do
        delete "/api/course/courses/#{course.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:delete])
      end
    end
  end
end
