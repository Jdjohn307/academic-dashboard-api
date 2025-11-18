FactoryBot.define do
  factory :user_role_link, class: 'Api::Users::UserRoleLink' do
    association :user
    association :role
    status { "active" }

    # Traits for invalid/edge cases
    trait :user_role_link_missing_user do
      user { nil }
    end

    trait :user_role_link_missing_role do
      role { nil }
    end

    trait :user_role_link_invalid_status do
      status { "banana" }
    end
  end
end
