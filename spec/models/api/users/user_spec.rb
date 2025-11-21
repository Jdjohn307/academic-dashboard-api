require "rails_helper"

RSpec.describe Api::Users::User, type: :model do
  describe "Model Object Instantiation" do
    it "creates a valid user" do
      user = FactoryBot.create(:user)
      expect(user).to be_valid
    end
  end

  describe "Relationship Validation" do
    it { should have_many(:user_role_links) }
    it { should have_many(:grades) }
    it { should have_many(:course_schedule_links) }
  end

  describe "Validator Validation" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name) }

    it { should validate_presence_of(:email) }
    it { should validate_length_of(:email) }

    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password) }

    context "| 'status' Validator |" do
      subject { build(:user) }
      it do
        should validate_inclusion_of(:status)
          .in_array([ "active", "inactive", "archived" ])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
