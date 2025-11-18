require "rails_helper"

RSpec.describe Api::Users::Grade, type: :model do
  describe "Model Object Instantiation" do
    it "creates a valid grade" do
      grade = FactoryBot.create(:grade_record)
      expect(grade).to be_valid
    end
  end

  describe "Relationship Validation" do
    it { should belong_to(:user) }
    it { should belong_to(:course) }
    it { should have_many(:assignment_grade_links) }
  end

  describe "Validator Validation" do
    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) 
  }
    it { should validate_presence_of(:course_id) }
    it { should validate_numericality_of(:course_id) }

    it { should validate_numericality_of(:final_grade) }

    it { should validate_length_of(:comments) }
    
    context "| 'status' Validator |" do
      let!(:user) { create(:user) }
      let!(:course) { create(:course) }
      subject { build(:grade_record, user: user, course: course) }
      it do
        should validate_inclusion_of(:status)
          .in_array([ "active", "inactive", "posted", "archived" ])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
