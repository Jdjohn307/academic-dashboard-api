module Api
  module Assignment
    class SerializableAssignment < JSONAPI::Serializable::Resource
      type 'assignments'
      attributes :course_schedule_id, :due_date, :title, :description,
        :points_possible, :status
      belongs_to :course_schedule
      has_many :assignment_grade_links
    end
  end
end