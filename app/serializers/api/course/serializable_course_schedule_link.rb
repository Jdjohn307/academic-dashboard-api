module Api
  module Course
    class SerializableCourseScheduleLink < JSONAPI::Serializable::Resource
      type "course_schedule_links"
      attributes :user_id, :course_schedule_id, :status
    end
  end
end
