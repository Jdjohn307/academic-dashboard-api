require 'swagger_helper'

RSpec.describe "User Login API", swagger_doc: "v1/swagger.yaml", type: :request do
  let!(:active_user) { create(:user, email: "test@example.com", password: "Password123", password_confirmation: "Password123", status: "active") }
  let!(:inactive_user) { create(:user, email: "inactive@example.com", password: "Password123", password_confirmation: "Password123", status: "inactive") }

  path "/api/users/auth/login" do
    post("User Login") do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        required: [ "email", "password" ],
        properties: {
          email: { type: :string },
          password: { type: :string }
        }
      }

      response(200, "successful login") do
        let(:credentials) { { email: "test@example.com", password: "Password123" } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]["token"]).to be_present
          expect(json["data"]["user"]["email"]).to eq("test@example.com")
        end
      end

      response(401, "invalid login") do
        context "wrong password" do
          let(:credentials) { { email: "test@example.com", password: "wrong" } }
          run_test!
        end

        context "wrong email" do
          let(:credentials) { { email: "wrong@example.com", password: "Password123" } }
          run_test!
        end
      end

      response(403, "inactive user") do
        let(:credentials) { { email: "inactive@example.com", password: "Password123" } }
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["errors"].first["status"]).to eq("403")
          expect(json["errors"].first["title"]).to eq("Forbidden")
          expect(json["errors"].first["detail"]).to match(/not active/)
        end
      end
    end
  end

  path "/api/users/auth/logout" do
    post("Logout User") do
      tags "Authentication"
      produces "application/json"

      response(200, "logged out") do
        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]["message"]).to eq("Logged out successfully")
        end
      end
    end
  end
end
