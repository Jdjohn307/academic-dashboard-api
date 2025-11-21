FactoryBot.define do
  factory :user, class: 'Api::Users::User' do
    name { "Jane Doe" }
    email { "jane@example.com" }
    password { "securepassword" }
    password_confirmation { "securepassword" }

    status { "active" }

    # Traits for invalid/edge cases
    trait :user_missing_name do
      name { nil }
    end

    trait :user_invalid_email do
      email { nil }
    end

    trait :user_invalid_status do
      status { "banana" }
    end

    trait :user_name_too_long do
      name { "a" * 101 }
    end
  end
end
