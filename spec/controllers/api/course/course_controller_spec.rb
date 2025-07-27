require 'rails_helper'

RSpec.describe Api::Course::CourseController, type: :request do
  let(:valid_attributes) do
    {
      name: "Intro to AI",
      semester: "Fall",
      year: 2025,
      code: "AI101",
      status: "active"
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      semester: nil,
      year: nil,
      code: nil
    }
  end

  describe "POST /create" do
    it "creates a course with valid attributes" do
      expect {
        post "/api/course/courses", params: valid_attributes
      }.to change(Api::Course::Course, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create a course with invalid attributes" do
      expect {
        post "/api/course/courses", params: invalid_attributes
      }.to_not change(Api::Course::Course, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /index" do
    it "returns a list of courses" do
      create_list(:course, 3)
      get "/api/course/courses"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "GET /show" do
    it "returns a single course if found" do
      course = create(:course)
      get "/api/course/courses/#{course.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"]).to eq(course.id.to_s)
    end

    it "returns nil or error if course not found" do
      get "/api/course/courses/999999"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]).to be_nil
    end
  end

  describe "PATCH /update" do
    it "updates a course with valid attributes" do
      course = create(:course)
      patch "/api/course/courses/#{course.id}", params: { name: "Updated Name" }

      expect(response).to have_http_status(:created)
      expect(course.reload.name).to eq("Updated Name")
    end

    it "returns error for non-existent course" do
      patch "/api/course/courses/999999", params: { name: "Failing Update" }
      expect(response).to have_http_status(:not_found)
    end

    it "returns error for invalid updates" do
      course = create(:course)
      patch "/api/course/courses/#{course.id}", params: { year: nil }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /delete" do
    it "deletes an existing course" do
      course = create(:course)
      delete "/api/course/courses/#{course.id}"
      expect(response).to have_http_status(:no_content)
      expect(Api::Course::Course.exists?(course.id)).to be false
    end

    it "returns error if course does not exist" do
      delete "/api/course/courses/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
