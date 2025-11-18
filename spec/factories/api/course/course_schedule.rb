FactoryBot.define do
  factory :course_schedule, class: 'Api::Course::CourseSchedule' do
    name { "MWF Schedule" }
    association :course
    start_date { Date.today }
    end_date { Date.today + 4.months }
    schedule_json { {
      "monday" => [ { "start" => "09:00", "end" => "10:30" } ],
      "wednesday" => [ { "start" => "13:00", "end" => "14:30" } ]
    } }
    status { "active" }
  end

  # Traits for invalid schedule_json cases
  trait :course_schedule_invalid_day do
    schedule_json do
      {
        "applesauce" => [ { "start" => "09:00", "end" => "10:30" } ],
        "wednesday" => [ { "start" => "13:00", "end" => "14:30" } ]
      }
    end
  end

  trait :course_schedule_invalid_time_key do
    schedule_json do
      {
        "tuesday" => [ { "ferret" => "09:00", "end" => "10:30" } ],
        "wednesday" => [ { "start" => "13:00", "end" => "14:30" } ]
      }
    end
  end

  trait :course_schedule_invalid_time_value do
    schedule_json do
      {
        "tuesday" => [ { "start" => "25:00", "end" => "10:30" } ],
        "wednesday" => [ { "start" => "13:00", "end" => "14:30" } ]
      }
    end
  end

  trait :course_schedule_invalid_no_array do
    schedule_json do
      {
        "tuesday" => { "start" => "9:00", "end" => "10:30" },
        "wednesday" => { "start" => "13:00", "end" => "14:30" }
      }
    end
  end

  trait :course_schedule_invalid_json_string do
    schedule_json { '"tuesday": {"start":"9:00"}' } # malformed JSON
  end
end
