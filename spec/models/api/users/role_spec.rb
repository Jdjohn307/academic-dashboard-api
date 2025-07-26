require "rails_helper"

RSpec.describe Api::Users::Role, type: :model do
  it "creates a valid role" do
    role = FactoryBot.create(:role)
    expect(role).to be_valid
  end
end