module Api
  module Course
    class CourseSchedule < ApplicationRecord
      self.table_name = 'course_schedule'
      belongs_to :course, class_name: 'Api::Course::Course', foreign_key: 'course_id', inverse_of: :course_schedules
      has_many :course_schedule_overrides, class_name: 'Api::Course::CourseScheduleOverride', foreign_key: 'course_schedule_id', inverse_of: :course_schedule
      has_many :course_schedule_links, class_name: 'Api::Course::CourseScheduleLink', foreign_key: 'course_schedule_id', inverse_of: :course_schedule
      has_many :assignments, class_name: 'Api::Assignment::Assignment', foreign_key: 'course_schedule_id', inverse_of: :course_schedule
    end
  end
end