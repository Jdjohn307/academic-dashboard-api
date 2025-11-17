module Api
  module Course
    class SerializableCourseScheduleOverride < JSONAPI::Serializable::Resource
      attributes :course_schedule_id, :override_date, :schedule_json,
      :notes, :status
    end
  end
end
