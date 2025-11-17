require "rails_helper"

RSpec.describe Api::Course::CourseSchedule, type: :model do
  it "creates a valid course_schedule" do
    course_schedule = FactoryBot.create(:course_schedule)
    expect(course_schedule).to be_valid
  end
end
