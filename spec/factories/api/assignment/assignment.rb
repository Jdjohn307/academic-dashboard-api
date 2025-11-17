FactoryBot.define do
  factory :assignment, class: 'Api::Assignment::Assignment' do
    association :course_schedule
    due_date { Time.now + 7.days }
    title { "Sample Assignment" }
    description { "This is a test assignment." }
    points_possible { 100.0 }
    status { "active" }
  end
  factory :assignment_invalid_points, class: 'Api::Assignment::Assignment' do
    association :course_schedule
    due_date { Time.now + 7.days }
    title { "Sample Assignment" }
    description { "This is a test assignment." }
    points_possible { "Apples" }
    status { "active" }
  end
  factory :assignment_invalid_due_date, class: 'Api::Assignment::Assignment' do
    association :course_schedule
    due_date { Time.now + 7.months }
    title { "Sample Assignment" }
    description { "This is a test assignment." }
    points_possible { 100.0 }
    status { "active" }
  end
end
