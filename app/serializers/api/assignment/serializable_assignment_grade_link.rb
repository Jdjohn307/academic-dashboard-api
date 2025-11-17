module Api
  module Assignment
    class SerializableAssignmentGradeLink < JSONAPI::Serializable::Resource
      attributes :grade_id, :assignment_id, :submitted_at, :graded_at,
        :grade, :points, :feedback, :status
    end
  end
end
