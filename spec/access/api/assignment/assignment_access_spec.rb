
require "rails_helper"

RSpec.describe "Assignments Access Control", type: :request do
  let!(:user) { create(:user, password: "Password123!", password_confirmation: "Password123!") }
  let(:auth_headers) { auth_header_for(user) }

  ROLES = [
    { role_name: 'role_student', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_teacher', perms: { read: 200, create: 201, update: 200, delete: 204 } },
    { role_name: 'role_ta', perms: { read: 200, create: 403, update: 403, delete: 403 } },
    { role_name: 'role_general_staff', perms: { read: 200, create: 403, update: 403, delete: 403 } }
  ]

  let!(:course) { create(:course) }
  let!(:course_schedule) { create(:course_schedule, course: course) }
  let!(:assignment) { create(:assignment, course_schedule: course_schedule) }

  ROLES.each do |entry|
    context "as #{entry[:role_name]}" do
      let!(:role) { create(:role, entry[:role_name]) }
      let!(:user_role_link) { create(:user_role_link, role: role, user: user) }

      it "evaluates index permissions correctly" do
        get "/api/assignment/assignments", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates show permissions correctly" do
        get "/api/assignment/assignments/#{assignment.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:read])
      end

      it "evaluates create permissions correctly" do
        post "/api/assignment/assignments", params: attributes_for(:assignment).merge(course_schedule_id: course_schedule.id), headers: auth_headers
        expect(response.status).to eq(entry[:perms][:create])
      end

      it "evaluates update permissions correctly" do
        put "/api/assignment/assignments/#{assignment.id}", params: { title: 'New Title' }, headers: auth_headers
        expect(response.status).to eq(entry[:perms][:update])
      end

      it "evaluates delete permissions correctly" do
        delete "/api/assignment/assignments/#{assignment.id}", headers: auth_headers
        expect(response.status).to eq(entry[:perms][:delete])
      end
    end
  end
end
