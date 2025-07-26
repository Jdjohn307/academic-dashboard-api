require "rails_helper"

RSpec.describe Api::Assignment::AssignmentGradeLink, type: :model do
  it "creates a valid assignment_grade_link" do
    assignment_grade_link = FactoryBot.create(:assignment_grade_link)
    expect(assignment_grade_link).to be_valid
  end
end