module Api
  module Course
    class Course < ApplicationRecord
      self.table_name = 'course'
      has_many :course_schedules, class_name: 'Api::Course::CourseSchedule', foreign_key: 'course_id', inverse_of: :course
      has_many :grades, class_name: 'Api::Users::Grade', foreign_key: 'course_id', inverse_of: :course
    end
  end
end