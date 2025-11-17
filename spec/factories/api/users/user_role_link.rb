FactoryBot.define do
  factory :user_role_link, class: 'Api::Users::UserRoleLink' do
    association :user
    association :role
    status { "active" }
  end
end
