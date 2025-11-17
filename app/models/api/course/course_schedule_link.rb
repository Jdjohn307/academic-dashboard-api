module Api
  module Course
    class CourseScheduleLink < ApplicationRecord
      self.table_name = "course_schedule_link"
      belongs_to :course_schedule, class_name: "Api::Course::CourseSchedule", foreign_key: "course_schedule_id", inverse_of: :course_schedule_links
      belongs_to :user, class_name: "Api::Users::User", foreign_key: "user_id", inverse_of: :course_schedule_links
    end
  end
end
