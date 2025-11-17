FactoryBot.define do
  factory :course_schedule, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { { monday: [ "9:00", "10:00" ] } }
    status { "active" }
  end
end
