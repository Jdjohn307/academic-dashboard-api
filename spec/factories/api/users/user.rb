FactoryBot.define do
  factory :user,  class: 'Api::Users::User' do
    name { "Jane Doe" }
    email { "jane@example.com" }
    encrypted_password { "securepassword" }
    status { "active" }
  end
end
