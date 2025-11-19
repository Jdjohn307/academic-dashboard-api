module Api
  module Assignment
    class AssignmentGradeLink < ApplicationRecord
      self.table_name = "assignment_grade_link"

      validates :grade_id, presence: true, numericality: {
        greater_than_or_equal_to: 0, only_integer: true
      }
      validates :assignment_id, presence: true, numericality: {
        greater_than_or_equal_to: 0, only_integer: true
      }

      validates :points, numericality: { greater_than_or_equal_to: 0, allow_nil: true }, comparison: {
        less_than_or_equal_to: ->(assignment_grade_link) { assignment_grade_link.assignment&.points_possible },
        allow_nil: true
      }
      validates :status, inclusion: {
        in: [ "active", "inactive", "submitted", "graded", "archived" ],
        message: "%{value} is not a valid status"
      }
      validates :feedback, length: {
        maximum: 500,
        too_long: "%{count} characters is the maximum allowed"
      }

      # Association is called "grade_record" to avoid issues with conflicting column named "grade"
      belongs_to :grade_record, class_name: "Api::Users::Grade", foreign_key: "grade_id", required: true, inverse_of: :assignment_grade_links
      belongs_to :assignment, class_name: "Api::Assignment::Assignment", foreign_key: "assignment_id", required: true, inverse_of: :assignment_grade_links

      # Validation for presence of associated records
      validates :grade_record, presence: true
      validates :assignment, presence: true
    end
  end
end
