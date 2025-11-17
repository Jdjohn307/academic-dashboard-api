FactoryBot.define do
  factory :course_schedule, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "monday": [
        { "start": "09:00", "end": "10:30" }
      ],
      "wednesday": [
        { "start": "13:00", "end": "14:30" }
      ]
    } }
    status { "active" }
  end
  factory :course_schedule_invalid_json_day, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "applesauce": [
        { "start": "09:00", "end": "10:30" }
      ],
      "wednesday": [
        { "start": "13:00", "end": "14:30" }
      ]
    } }
    status { "active" }
  end
  factory :course_schedule_invalid_json_time_key, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "tuesday": [
        { "ferret": "09:00", "end": "10:30" }
      ],
      "wednesday": [
        { "start": "13:00", "end": "14:30" }
      ]
    } }
    status { "active" }
  end
  factory :course_schedule_invalid_json_time_value, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "tuesday": [
        { "start": "25:00", "end": "10:30" }
      ],
      "wednesday": [
        { "start": "13:00", "end": "14:30" }
      ]
    } }
    status { "active" }
  end
  factory :course_schedule_invalid_json_no_array, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "tuesday": { "start": "9:00", "end": "10:30" },
      "wednesday": { "start": "13:00", "end": "14:30" }
    } }
    status { "active" }
  end
  factory :course_schedule_invalid_json, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { '
      "tuesday": { "start": "9:00", "end": "10:30" },
      "wednesday": { "start": "13:00", "end": "14:30" }
    ' }
    status { "active" }
  end
end
