module Api
  module Users
    class Grade < ApplicationRecord
      self.table_name = "grade"

      # Validation
      validates :user_id, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
      validates :course_id, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
      validates :final_grade, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
      validates :comments, length: {
        maximum: 500,
        too_long: "%{count} characters is the maximum allowed"
      }, allow_nil: true
      validates :status, inclusion: {
        in: [ "active", "inactive", "posted", "archived" ],
        message: "%{value} is not a valid status"
      }, allow_nil: true

      belongs_to :user, class_name: "Api::Users::User", foreign_key: "user_id", required: true, inverse_of: :grades
      belongs_to :course, class_name: "Api::Course::Course", foreign_key: "course_id", required: true, inverse_of: :grades
      # Association is called "grade_record" to avoid issues with conflicting column named "grade"
      has_many :assignment_grade_links, class_name: "Api::Assignment::AssignmentGradeLink", foreign_key: "grade_id", inverse_of: :grade_record

      # Validation for presence of associated records
      validates :user, presence: true
      validates :course, presence: true
    end
  end
end
