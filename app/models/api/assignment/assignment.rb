module Api
  module Assignment
    class Assignment < ApplicationRecord
      self.table_name = 'assignment'
      belongs_to :course_schedule, class_name: 'Api::Course::CourseSchedule', foreign_key: 'course_schedule_id', required: true, inverse_of: :assignments
      has_many :assignment_grade_links, class_name: 'Api::Assignment::AssignmentGradeLink', foreign_key: 'assignment_id', inverse_of: :assignment
    end
  end
end