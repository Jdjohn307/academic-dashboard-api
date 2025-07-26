FactoryBot.define do
  factory :course_schedule_override, class: 'Api::Course::CourseScheduleOverride' do
    association :course_schedule
    override_date { Date.today + 1.week }
    schedule_json { { tuesday: ["12:00", "13:00"] } }
    notes { "Holiday adjustment" }
    status { "active" }
  end
end