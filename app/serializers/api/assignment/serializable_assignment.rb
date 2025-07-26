module Api
  module Assignment
    class SerializableAssignment < JSONAPI::Serializable::Resource
      attributes :course_schedule_id, :due_date, :title, :description,
        :points_possible, :status
    end
  end
end