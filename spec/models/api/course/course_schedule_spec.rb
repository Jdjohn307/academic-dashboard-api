require "rails_helper"

RSpec.describe Api::Course::CourseSchedule, type: :model do
   describe "Model Object Instantion" do
    it "creates a valid course_schedule" do
      course_schedule = FactoryBot.create(:course_schedule)
      expect(course_schedule).to be_valid
    end
  end

  describe "Relationship Validation" do
    # Relationships
    it { should belong_to(:course) }
    it { should have_many(:course_schedule_links) }
    it { should have_many(:course_schedule_overrides) }
    it { should have_many(:assignments) }
  end

  describe "Validator Validation" do
    # Validation
    it { should validate_presence_of(:course_id) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name) }

    it { should validate_presence_of(:start_date) }

    context "| 'end_date' Validator |" do
    it { should validate_presence_of(:end_date) }
      let!(:course) { create(:course) }
      subject { build(:course_schedule, course: course) }
      it { should validate_comparison_of(:end_date).is_greater_than_or_equal_to(:start_date) }
    end

    # shoulda-matches can not validate dynamic values
    context "| 'status' Validator |" do
      it { should_not validate_presence_of(:status) }
      let!(:course) { create(:course) }

      subject { build(:course_schedule, course: course) }

      it do
        should validate_inclusion_of(:status)
          .in_array(%w[active complete hold archived])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end

    # shoulda-matches can not custom validations
    context "| 'schedule_json' Validator |" do
      let!(:course) { create(:course) }
      subject { build(:course_schedule, course: course) }

      it "is valid with a proper schedule_json" do
        course_schedule = build(:course_schedule, course: course)
        expect(course_schedule).to be_valid
      end

      it "adds an error if schedule_json is not a hash or JSON object" do
        course_schedule = build(:course_schedule, :course_schedule_invalid_json_string, course: course)
        course_schedule.valid?
        expect(course_schedule.errors[:schedule_json]).to include("must be a valid JSON object")
      end

      it "adds an error if a day is invalid" do
        course_schedule = build(:course_schedule, :course_schedule_invalid_day, course: course)
        course_schedule.valid?
        expect(course_schedule.errors[:schedule_json]).to include(/contains invalid day:/)
      end

      it "adds an error if the value for a day is not an array" do
        course_schedule = build(:course_schedule, :course_schedule_invalid_no_array, course: course)
        course_schedule.valid?
        expect(course_schedule.errors[:schedule_json]).to include(/must be an array of time periods/)
      end

      it "adds an error if a period is not a hash or missing keys" do
        course_schedule = build(:course_schedule, :course_schedule_invalid_time_key, course: course)
        course_schedule.valid?
        expect(course_schedule.errors[:schedule_json]).to include(/must be a hash with 'start' and 'end' keys/)
      end

      it "adds an error if a time is not in HH:MM format" do
        course_schedule = build(:course_schedule, :course_schedule_invalid_time_value, course: course)
        course_schedule.valid?
        expect(course_schedule.errors[:schedule_json].join).to match(/must be a string in HH:MM format/)
      end

      it "can handle empty schedule_json as valid" do
        course_schedule = build(:course_schedule, schedule_json: {}, course: course)
        expect(course_schedule).to be_valid
      end
    end
  end
end
