require "rails_helper"

RSpec.describe Api::Users::UserRoleLink, type: :model do
  describe "Model Object Instantiation" do
    it "creates a valid user_role_link" do
      user_role_link = FactoryBot.create(:user_role_link)
      expect(user_role_link).to be_valid
    end
  end

  describe "Relationship Validation" do
    it { should belong_to(:user) }
    it { should belong_to(:role) }
  end

  describe "Validator Validation" do
    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }

    it { should validate_presence_of(:role_id) }
    it { should validate_numericality_of(:role_id) }

    context "| 'status' Validator |" do
      let!(:user) { create(:user) }
      let!(:role) { create(:role) }
      subject { build(:user_role_link, user: user, role: role) }
      it do
        should validate_inclusion_of(:status)
          .in_array([ "active", "inactive", "archived" ])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
