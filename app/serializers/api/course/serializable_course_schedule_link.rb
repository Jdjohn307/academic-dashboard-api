module Api
  module Course
    class SerializableCourseScheduleLink < JSONAPI::Serializable::Resource
      attributes :user_id, :course_schedule_id, :status
    end
  end
end