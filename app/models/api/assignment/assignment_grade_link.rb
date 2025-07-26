module Api
  module Assignment
    class AssignmentGradeLink < ApplicationRecord
      self.table_name = 'assignment_grade_link'
      # Association is called "grade_record" to avoid issues with conflicting column named "grade"
      belongs_to :grade_record, class_name: 'Api::Users::Grade', foreign_key: 'grade_id', required: true, inverse_of: :assignment_grade_links
      belongs_to :assignment, class_name: 'Api::Assignment::Assignment', foreign_key: 'assignment_id', required: true, inverse_of: :assignment_grade_links
    end
  end
end