require "rails_helper"

RSpec.describe Api::Course::CourseScheduleOverride, type: :model do
  it "creates a valid course_schedule_override" do
    course_schedule_override = FactoryBot.create(:course_schedule_override)
    expect(course_schedule_override).to be_valid
  end
end
