require "rails_helper"

RSpec.describe Api::Course::Course, type: :model do
  it "creates a valid course" do
    course = FactoryBot.create(:course)
    expect(course).to be_valid
  end
end
