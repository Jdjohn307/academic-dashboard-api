module Api
  module Course
    class SerializableCourseSchedule < JSONAPI::Serializable::Resource
      type "course_schedules"
      attributes :name, :course_id, :start_date, :end_date,
      :schedule_json, :status
    end
  end
end
