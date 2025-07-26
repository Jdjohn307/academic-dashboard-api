FactoryBot.define do
  factory :course, class: 'Api::Course::Course' do
    name { "Biology 101" }
    semester { "Fall" }
    year { "2025" }
    code { "BIO101" }
    status { "active" }
  end
end