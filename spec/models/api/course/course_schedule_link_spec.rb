require "rails_helper"

RSpec.describe Api::Course::CourseScheduleLink, type: :model do
  it "creates a valid course_schedule_link" do
    course_schedule_link = FactoryBot.create(:course_schedule_link)
    expect(course_schedule_link).to be_valid
  end
end