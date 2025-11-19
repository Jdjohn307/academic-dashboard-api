require 'rails_helper'

RSpec.describe Api::Users::GradesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:course) { create(:course) }

  # Index
  describe "GET #index" do
    it "returns all grades" do
      create_list(:grade_record, 3, user: user, course: course)
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
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns a grade by id" do
      grade = create(:grade_record, user: user, course: course)
      get :show, params: { id: grade.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq("#{grade.id}")
      expect(JSON.parse(response.body)['data']['attributes'].keys).to include('final_grade', 'comments', 'status')
    end
  end

  # Create
  describe "POST #create" do
    context "with valid attributes" do
      it "creates a grade" do
        valid_params = attributes_for(:grade_record).merge(user_id: user.id, course_id: course.id)
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['attributes'].keys).to include('final_grade', 'comments', 'status')
      end
    end
    context "with invalid attributes" do
      it "returns errors for missing parameters" do
        post :create, params: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
      it "returns errors for invalid parameters" do
        post :create, params: { user_id: nil, course_id: nil }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  # Update
  describe "PATCH #update" do
    let!(:grade) { create(:grade_record, user: user, course: course, final_grade: 85.0) }
    it "updates a grade" do
      patch :update, params: { id: grade.id, final_grade: 90.5 }
      expect(response).to have_http_status(:ok)
      expect(grade.reload.final_grade).to eq(90.5)
    end
    it "renders error when not found" do
      patch :update, params: { id: -99, final_grade: 90.5 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
    it "returns errors for invalid parameters" do
      patch :update, params: { id: grade.id, final_grade: -1 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'][0]['detail']).to eq("Final grade must be greater than or equal to 0")
    end
  end

  # Destroy
  describe "DELETE #destroy" do
    let!(:grade) { create(:grade_record, user: user, course: course) }
    it "deletes a grade" do
      delete :destroy, params: { id: grade.id }
      expect(response).to have_http_status(:no_content)
      expect(Api::Users::Grade.exists?(grade.id)).to be_falsey
    end
    it "renders error when not found" do
      delete :destroy, params: { id: -99 }
      expect(response).to have_http_status(:not_found)
      error = JSON.parse(response.body)['errors'][0]
      expect(error['title']).to eq('Not Found')
      expect(error['status']).to eq('404')
      expect(error['detail']).to match(/couldn't find/i)
    end
  end
end
