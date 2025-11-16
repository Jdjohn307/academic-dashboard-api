require "rails_helper"

RSpec.describe Api::Assignment::AssignmentGradeLink, type: :model do
  describe "Model Object Instantion" do
    it "creates a valid assignment_grade_link" do
      assignment_grade_link = FactoryBot.create(:assignment_grade_link)
      expect(assignment_grade_link).to be_valid
    end
  end
  
  describe "Relationship Validation" do
    # Relationships
    it { should belong_to(:grade_record) }
    it { should belong_to(:assignment) }
  end

  describe "Validator Validation" do
    # Validation
    it { should validate_presence_of(:grade_id) }
    it { should validate_numericality_of(:grade_id) }

    it { should validate_presence_of(:assignment_id) }
    it { should validate_numericality_of(:assignment_id) }

    it { should_not validate_presence_of(:feedback) }
    it { should validate_length_of(:feedback) }

    context "| 'status' Validator |" do
      it { should_not validate_presence_of(:status) }
      let!(:course) { create(:course) }
      let!(:course_schedule) { create(:course_schedule, course: course) }

      subject { build(:assignment, course_schedule: course_schedule) }

      it do
        should validate_inclusion_of(:status)
          .in_array(%w(active inactive draft published submitted graded archived))
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end

    # shoulda-matches can not validate dynamic values
    context "| 'points' Validator |" do
      it { should_not validate_presence_of(:points) }
      it { should validate_numericality_of(:points) }
      
      let!(:assignment) { create(:assignment) }
      let!(:grade_record) { create(:grade_record) }
      it "is invalid if points is more than the assignment's points_possible" do
        assignment_grade_link = build(:assignment_grade_link_invalid_points, assignment: assignment, grade_record: grade_record)
        expect(assignment_grade_link).not_to be_valid
        expect(assignment_grade_link.errors[:points]).to include("must be less than or equal to #{assignment.points_possible}")
      end

      it "is valid if points is less than or eqaul to the assignment's points_possible" do
        assignment_grade_link = build(:assignment_grade_link, assignment: assignment, grade_record: grade_record)
        expect(assignment_grade_link).to be_valid
      end
    end
  end
end