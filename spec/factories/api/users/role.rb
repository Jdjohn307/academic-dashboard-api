FactoryBot.define do
  factory :role, class: 'Api::Users::Role' do
    name { "Student" }
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
  end
end
