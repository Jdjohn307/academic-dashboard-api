module Api
  module Course
    class CourseScheduleOverride < ApplicationRecord
      self.table_name = 'course_schedule_override'
      belongs_to :course_schedule, class_name: 'Api::Course::CourseSchedule', foreign_key: 'course_schedule_id', inverse_of: :course_schedule_overrides
    end
  end
end