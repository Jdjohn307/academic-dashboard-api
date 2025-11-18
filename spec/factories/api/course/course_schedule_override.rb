FactoryBot.define do
  factory :course_schedule_override, class: 'Api::Course::CourseScheduleOverride' do
    association :course_schedule
    override_date { Date.today + 1.week }
    schedule_json { { "tuesday" => [ { "start" => "12:00", "end" => "13:00" } ] } }
    notes { "Holiday adjustment" }
    status { "active" }

    # Traits for invalid schedule_json cases
    trait :course_schedule_override_invalid_day do
      schedule_json do
        { "applesauce" => [ { "start" => "09:00", "end" => "10:30" } ] }
      end
    end

    trait :course_schedule_override_invalid_time_key do
      schedule_json do
        { "tuesday" => [ { "ferret" => "09:00", "end" => "10:30" } ] }
      end
    end

    trait :course_schedule_override_invalid_time_value do
      schedule_json do
        { "tuesday" => [ { "start" => "25:00", "end" => "10:30" } ] }
      end
    end

    trait :course_schedule_override_invalid_no_array do
      schedule_json do
        { "tuesday" => { "start" => "9:00", "end" => "10:30" } }
      end
    end

    trait :course_schedule_override_invalid_json_string do
      schedule_json { '"tuesday": {"start":"9:00"}' } # malformed JSON
    end
  end
end
