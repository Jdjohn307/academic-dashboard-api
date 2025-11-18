require "rails_helper"

RSpec.describe Api::Users::Role, type: :model do
  describe "Model Object Instantiation" do
    it "creates a valid role" do
      role = FactoryBot.create(:role)
      expect(role).to be_valid
    end
  end

  describe "Relationship Validation" do
    it { should have_many(:user_role_links) }
  end

  describe "Validator Validation" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name) }

    context "| 'status' Validator |" do
      subject { build(:role) }
      it do
        should validate_inclusion_of(:status)
          .in_array([ "active", "inactive", "archived" ])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
