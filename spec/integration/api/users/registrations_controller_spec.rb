require 'swagger_helper'

RSpec.describe "User Registration API", swagger_doc: "v1/swagger.yaml", type: :request do
  path "/api/users/auth/register" do
    post("Register User") do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        required: [ "name", "email", "password", "password_confirmation" ],
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        }
      }

      response(201, "created") do
        let(:user) { { name: "New User", email: "new@example.com", password: "Password123", password_confirmation: "Password123" } }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json["data"]["token"]).to be_present
          expect(json["data"]["user"]["name"]).to eq("New User")
          expect(json["data"]["user"]["email"]).to eq("new@example.com")
        end
      end

      response(422, "validation error") do
        context "password confirmation mismatch" do
          let(:user) { { name: "A", email: "a@example.com", password: "123", password_confirmation: "321" } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["errors"].first["status"]).to eq("422")
            expect(json["errors"].first["title"]).to eq("Unprocessable Entity")
            expect(json["errors"].first["detail"]).to match(/does not match/)
          end
        end

        context "missing required fields" do
          let(:user) { { name: "", email: "", password: "", password_confirmation: "" } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["errors"]).not_to be_empty
          end
        end

        context "email already taken" do
          before { create(:user, email: "taken@example.com") }
          let(:user) { { name: "Test", email: "taken@example.com", password: "Password123", password_confirmation: "Password123" } }

          run_test! do |response|
            json = JSON.parse(response.body)
            expect(json["errors"].first["status"]).to eq("422")
            expect(json["errors"].first["detail"]).to match(/has already been taken/)
          end
        end
      end
    end
  end
end
