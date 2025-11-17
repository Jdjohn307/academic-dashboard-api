FactoryBot.define do
  factory :course_schedule_link, class: 'Api::Course::CourseScheduleLink' do
    association :user
    association :course_schedule
    status { "enrolled" }
  end
end
