require "rails_helper"

RSpec.describe Api::Users::Grade, type: :model do
  it "creates a valid grade" do
    grade = FactoryBot.create(:grade_record)
    expect(grade).to be_valid
  end
end
