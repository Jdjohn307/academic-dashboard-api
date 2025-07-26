FactoryBot.define do
  factory :role, class: 'Api::Users::Role' do
    name { "Student" }
    status { "active" }
  end
end