require "rails_helper"

RSpec.describe Api::Course::Course, type: :model do
   describe "Model Object Instantion" do
    it "creates a valid course" do
      course = FactoryBot.create(:course)
      expect(course).to be_valid
    end
  end

  describe "Relationship Validation" do
    # Relationships
    it { should have_many(:course_schedules) }
    it { should have_many(:grades) }
  end

  describe "Validator Validation" do
    # Validation
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name) }

    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code) }

    it { should validate_presence_of(:year) }
    it { should validate_numericality_of(:year) }

    context "| 'semester' Validator |" do
      it { should validate_presence_of(:semester) }

      subject { build(:course) }

      it do
        should validate_inclusion_of(:semester)
          .in_array(%w[spring summer winter fall])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid semester")
      end
    end

    context "| 'status' Validator |" do
      it { should_not validate_presence_of(:status) }

      subject { build(:course) }

      it do
        should validate_inclusion_of(:status)
          .in_array(%w[active inactive archived])
          .with_message("#{Shoulda::Matchers::ExampleClass} is not a valid status")
      end
    end
  end
end
