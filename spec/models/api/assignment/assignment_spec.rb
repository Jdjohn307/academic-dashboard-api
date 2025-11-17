require "rails_helper"

RSpec.describe Api::Assignment::Assignment, type: :model do
  describe "Model Object Instantion" do
    it "creates a valid assignment" do
      assignment = FactoryBot.create(:assignment)
      expect(assignment).to be_valid
    end
  end

  describe "Relationship Validation" do
    # Relationships
    it { should belong_to(:course_schedule) }
    it { should have_many(:assignment_grade_links) }
  end

  describe "Validator Validation" do
    # Validation
    it { should validate_presence_of(:course_schedule_id) }

    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title) }

    it { should_not validate_presence_of(:description) }
    it { should validate_length_of(:description) }

    it { should validate_presence_of(:points_possible) }
    it { should validate_numericality_of(:points_possible) }

    context "| 'status' Validator |" do
      it { should_not validate_presence_of(:status) }
      let!(:course) { create(:course) }
      let!(:course_schedule) { create(:course_schedule, course: course) }

      subject { build(:assignment, course_schedule: course_schedule) }

      it do
        should validate_inclusion_of(:status)
          .in_array(%w[active inactive draft published submitted graded archived])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end

    # shoulda-matches can not validate dynamic values
    context "| 'due_date' Validator |" do
      it { should validate_presence_of(:due_date) }
      let!(:course) { create(:course) }
      let!(:course_schedule) { create(:course_schedule, course: course) }
      it "is invalid if due_date is after the course_schedule end_date" do
        assignment = build(:assignment_invalid_due_date, course_schedule: course_schedule)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:due_date]).to include("must be less than or equal to #{course_schedule.end_date}")
      end

      it "is valid if due_date is on or before the course_schedule end_date" do
        assignment = build(:assignment, course_schedule: course_schedule, due_date: course_schedule.end_date)
        expect(assignment).to be_valid
      end
    end
  end
end
