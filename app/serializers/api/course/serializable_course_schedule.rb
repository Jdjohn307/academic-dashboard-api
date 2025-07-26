module Api
  module Course
    class SerializableCourseSchedule < JSONAPI::Serializable::Resource
      attributes :name, :course_id, :start_date, :end_date, 
      :schedule_json, :status
    end
  end
end