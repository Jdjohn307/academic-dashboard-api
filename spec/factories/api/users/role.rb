FactoryBot.define do
  factory :role, class: 'Api::Users::Role' do
    name { "Administrator" }
    status { "active" }

    # Traits for invalid/edge cases
    trait :role_missing_name do
      name { nil }
    end

    trait :role_invalid_status do
      status { "banana" }
    end

    trait :role_name_too_long do
      name { "a" * 101 }
    end

    trait :role_student do
      name { "Student" }
    end

    trait :role_teacher do
      name { "Teacher" }
    end

    trait :role_ta do
      name { "Teaching Assistant" }
    end

    trait :role_general_staff do
      name { "General Staff" }
    end
  end
end
