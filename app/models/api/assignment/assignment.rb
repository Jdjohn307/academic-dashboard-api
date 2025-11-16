module Api
  module Assignment
    class Assignment < ApplicationRecord
      self.table_name = 'assignment'
      validates :course_schedule_id, presence: true
      validates :due_date,
        presence: true,
        comparison: {
          less_than_or_equal_to: ->(assignment) { assignment.course_schedule&.end_date }
        }
      validates :title, presence: true, length: { 
        maximum: 100,
        too_long: "%{count} characters is the maximum allowed"
      }
      validates :points_possible, presence: true, numericality: {greater_than_or_equal_to: 0}
      validates :description, length: { 
        maximum: 500,
        too_long: "%{count} characters is the maximum allowed"
      }

      validates :status, inclusion: { 
        in: ['active', 'inactive', 'draft', 'published', 'archived'],
        message: "%{value} is not a valid status" 
      }

      belongs_to :course_schedule, class_name: 'Api::Course::CourseSchedule', foreign_key: 'course_schedule_id', required: true, inverse_of: :assignments
      has_many :assignment_grade_links, class_name: 'Api::Assignment::AssignmentGradeLink', foreign_key: 'assignment_id', inverse_of: :assignment
    end
  end
end