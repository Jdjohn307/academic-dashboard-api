require "rails_helper"

RSpec.describe Api::Course::CourseScheduleLink, type: :model do
  describe "Model Object Instantion" do
    it "creates a valid course_schedule_link" do
      course_schedule_link = FactoryBot.create(:course_schedule_link)
      expect(course_schedule_link).to be_valid
    end
  end

  describe "Relationship Validation" do
    # Relationships
    it { should belong_to(:course_schedule) }
    it { should belong_to(:user) }
  end

  describe "Validator Validation" do
    # Validation
    it { should validate_presence_of(:course_schedule_id) }
    it { should validate_numericality_of(:course_schedule_id) }

    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }

    # shoulda-matches can not validate dynamic values
    context "| 'status' Validator |" do
      it { should_not validate_presence_of(:status) }
      let!(:course_schedule) { create(:course_schedule) }
      let!(:user) { create(:user) }

      subject { build(:course_schedule_link, course_schedule: course_schedule, user: user) }

      it do
        should validate_inclusion_of(:status)
          .in_array(%w[active inactive hold completed archived])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
