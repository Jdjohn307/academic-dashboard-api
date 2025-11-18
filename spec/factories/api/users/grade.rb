FactoryBot.define do
  factory :grade_record, class: 'Api::Users::Grade' do
    association :user
    association :course
    final_grade { 90.0 }
    comments { "Final grade comment." }
    status { "posted" }

    # Traits for invalid/edge cases
    trait :grade_missing_user do
      user { nil }
    end

    trait :grade_missing_course do
      course { nil }
    end

    trait :grade_invalid_status do
      status { "banana" }
    end

    trait :grade_comments_too_long do
      comments { "a" * 501 }
    end
  end
end
