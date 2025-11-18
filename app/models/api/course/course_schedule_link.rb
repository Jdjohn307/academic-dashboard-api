module Api
  module Course
    class CourseScheduleLink < ApplicationRecord
      self.table_name = "course_schedule_link"

      validates :user_id, presence: true, numericality: {
        greater_than_or_equal_to: 0, only_integer: true
      }
      validates :course_schedule_id, presence: true, numericality: {
        greater_than_or_equal_to: 0, only_integer: true
      }
      validates :status, inclusion: {
        in: [ "active", "inactive", "completed", "hold", "archived" ],
        message: "%{value} is not a valid status"
      }

      belongs_to :course_schedule, class_name: "Api::Course::CourseSchedule", foreign_key: "course_schedule_id", inverse_of: :course_schedule_links
      belongs_to :user, class_name: "Api::Users::User", foreign_key: "user_id", inverse_of: :course_schedule_links
    end
  end
end
