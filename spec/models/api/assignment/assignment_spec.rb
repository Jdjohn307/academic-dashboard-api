require "rails_helper"

RSpec.describe Api::Assignment::Assignment, type: :model do
  it "creates a valid assignment" do
    assignment = FactoryBot.create(:assignment)
    expect(assignment).to be_valid
  end
end