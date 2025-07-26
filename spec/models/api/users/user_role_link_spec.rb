require "rails_helper"

RSpec.describe Api::Users::UserRoleLink, type: :model do
  it "creates a valid user_role_link" do
    user_role_link = FactoryBot.create(:user_role_link)
    expect(user_role_link).to be_valid
  end
end