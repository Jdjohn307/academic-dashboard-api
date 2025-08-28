require 'rails_helper'

RSpec.describe Api::Users::GradeController, type: :controller do
  let!(:user) { create(:user) }
  let!(:course) { create(:course) }

  describe "GET #index" do
    it "returns all grades" do
      create_list(:grade_record, 3, user: user, course: course)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns a grade by id" do
      grade = create(:grade_record, user: user, course: course)
      get :show, params: { id: grade.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{grade.id}")
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a grade" do
        valid_params = {
          user_id: user.id,
          course_id: course.id,
          final_grade: 95.0,
          comments: "Excellent work",
          status: "posted"
        }
        post :create, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['id']).to be_present
      end
    end

    context "with invalid attributes" do
      it "returns an error" do
        post :create, params: { user_id: nil, course_id: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end
  end

  describe "PATCH #update" do
    it "updates a grade" do
      grade = create(:grade_record, user: user, course: course, final_grade: 85.0)
      patch :update, params: { id: grade.id, final_grade: 90.5 }

      expect(response).to have_http_status(:ok)
      expect(grade.reload.final_grade).to eq(90.5)
    end
  end

  describe "DELETE #destroy" do
    it "deletes a grade" do
      grade = create(:grade_record, user: user, course: course)
      delete :destroy, params: { id: grade.id }

      expect(response).to have_http_status(:no_content)
      expect(Api::Users::Grade.exists?(grade.id)).to be_falsey
    end
  end
end