FactoryBot.define do
  factory :assignment, class: 'Api::Assignment::Assignment' do
    association :course_schedule
    due_date { Time.now + 7.days }
    title { "Sample Assignment" }
    description { "This is a test assignment." }
    points_possible { 100.0 }
    status { "active" }
  end

  # Traits for invalid cases
  trait :assignment_invalid_points do
    points_possible do
      "Apples"
    end
  end
  trait :assignment_invalid_due_date do
    due_date do
       Time.now + 7.months
    end
  end
end
