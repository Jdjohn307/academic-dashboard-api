module Api
  module Users
    class SerializableGrade < JSONAPI::Serializable::Resource
      type "grades"
      attributes :user_id, :course_id, :final_grade, :comments,
        :status
    end
  end
end
