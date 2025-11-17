module Api
  module Users
    class Grade < ApplicationRecord
      self.table_name = "grade"

      belongs_to :user, class_name: "Api::Users::User", foreign_key: "user_id", required: true, inverse_of: :grades
      belongs_to :course, class_name: "Api::Course::Course", foreign_key: "course_id", required: true, inverse_of: :grades
      # Association is called "grade_record" to avoid issues with conflicting column named "grade"
      has_many :assignment_grade_links, class_name: "Api::Assignment::AssignmentGradeLink", foreign_key: "grade_id", inverse_of: :grade_record
    end
  end
end
