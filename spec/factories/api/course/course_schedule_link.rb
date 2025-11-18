FactoryBot.define do
  factory :course_schedule_link, class: 'Api::Course::CourseScheduleLink' do
    association :user
    association :course_schedule
    status { "active" }
  end
end
