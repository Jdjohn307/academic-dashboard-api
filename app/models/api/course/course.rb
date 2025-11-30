module Api
  module Course
    class Course < ApplicationRecord
      self.table_name = "course"

      validates :name, presence: true, length: {
        maximum: 100,
        too_long: "%{count} characters is the maximum allowed"
      }
      validates :semester, presence: true, inclusion: {
        in: [ "winter", "summer", "spring", "fall" ],
        message: "%{value} is not a valid semester"
      }
      validates :year, presence: true, numericality: {
        greater_than_or_equal_to: 1900, only_integer: true
      }
      validates :code, presence: true, length: {
        maximum: 20,
        too_long: "%{count} characters is the maximum allowed"
      }
      validates :status, inclusion: {
        in: COURSE_STATUSES,
        message: "%{value} is not a valid status"
      }

      has_many :course_schedules, class_name: "Api::Course::CourseSchedule", foreign_key: "course_id", inverse_of: :course
      has_many :grades, class_name: "Api::Users::Grade", foreign_key: "course_id", inverse_of: :course
    end
  end
end
