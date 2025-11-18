
require "rails_helper"

RSpec.describe Api::Course::CourseScheduleOverride, type: :model do
  describe "Model Object Instantiation" do
    it "creates a valid course_schedule_override" do
      course_schedule_override = FactoryBot.create(:course_schedule_override)
      expect(course_schedule_override).to be_valid
    end
  end

  describe "Relationship Validation" do
    it { should belong_to(:course_schedule) }
  end

  describe "Validator Validation" do
    it { should validate_presence_of(:course_schedule_id) }
    it { should validate_presence_of(:notes) }
    it { should validate_length_of(:notes) }
    it { should validate_presence_of(:override_date) }

    context "| 'override_date' Validator |" do
      let!(:course_schedule) { create(:course_schedule) }
      subject { build(:course_schedule_override, course_schedule: course_schedule) }
      it {
        should validate_comparison_of(:override_date)
          .is_greater_than_or_equal_to(subject.course_schedule&.start_date)
      }
      it {
        should validate_comparison_of(:override_date)
          .is_less_than_or_equal_to(subject.course_schedule&.end_date)
      }
    end

    context "| 'status' Validator |" do
      let!(:course_schedule) { create(:course_schedule) }
      subject { build(:course_schedule_override, course_schedule: course_schedule) }
      it do
        should validate_inclusion_of(:status)
          .in_array(%w[active inactive archived])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end

    context "| 'schedule_json' Validator |" do
      let!(:course_schedule) { create(:course_schedule) }
      subject { build(:course_schedule_override, course_schedule: course_schedule) }

      it "is valid with a proper schedule_json" do
        course_schedule_override = build(:course_schedule_override, course_schedule: course_schedule)
        expect(course_schedule_override).to be_valid
      end

      it "adds an error if schedule_json is not a hash or JSON object" do
        course_schedule_override = build(:course_schedule_override, schedule_json: '"tuesday": {"start":"9:00"}', course_schedule: course_schedule)
        course_schedule_override.valid?
        expect(course_schedule_override.errors[:schedule_json]).to include("must be a valid JSON object")
      end

      it "adds an error if a day is invalid" do
        course_schedule_override = build(:course_schedule_override, schedule_json: { "applesauce" => [ { "start" => "09:00", "end" => "10:30" } ] }, course_schedule: course_schedule)
        course_schedule_override.valid?
        expect(course_schedule_override.errors[:schedule_json]).to include(/contains invalid day:/)
      end

      it "adds an error if the value for a day is not an array" do
        course_schedule_override = build(:course_schedule_override, schedule_json: { "tuesday" => { "start" => "9:00", "end" => "10:30" } }, course_schedule: course_schedule)
        course_schedule_override.valid?
        expect(course_schedule_override.errors[:schedule_json]).to include(/must be an array of time periods/)
      end

      it "adds an error if a period is not a hash or missing keys" do
        course_schedule_override = build(:course_schedule_override, schedule_json: { "tuesday" => [ { "ferret" => "09:00", "end" => "10:30" } ] }, course_schedule: course_schedule)
        course_schedule_override.valid?
        expect(course_schedule_override.errors[:schedule_json]).to include(/must be a hash with 'start' and 'end' keys/)
      end

      it "adds an error if a time is not in HH:MM format" do
        course_schedule_override = build(:course_schedule_override, schedule_json: { "tuesday" => [ { "start" => "25:00", "end" => "10:30" } ] }, course_schedule: course_schedule)
        course_schedule_override.valid?
        expect(course_schedule_override.errors[:schedule_json].join).to match(/must be a string in HH:MM format/)
      end

      it "can handle empty schedule_json as valid" do
        course_schedule_override = build(:course_schedule_override, schedule_json: {}, course_schedule: course_schedule)
        expect(course_schedule_override).to be_valid
      end
    end
  end
end
