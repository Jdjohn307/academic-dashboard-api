require "rails_helper"

RSpec.describe Api::Users::User, type: :model do
  it "creates a valid user" do
    user = FactoryBot.create(:user)
    expect(user).to be_valid
  end
end
