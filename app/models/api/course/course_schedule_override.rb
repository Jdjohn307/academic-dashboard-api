module Api
  module Course
    class CourseScheduleOverride < ApplicationRecord
      self.table_name = "course_schedule_override"

      validates :course_schedule_id, presence: true, numericality: {
        greater_than_or_equal_to: 0, only_integer: true
      }
      validates :notes, presence: true, length: {
        maximum: 500,
        too_long: "%{count} characters is the maximum allowed"
      }
      validates :override_date, presence: true, comparison: {
        greater_than_or_equal_to: ->(course_schedule_override) { course_schedule_override.course_schedule&.start_date },
        less_than_or_equal_to: ->(course_schedule_override) { course_schedule_override.course_schedule&.end_date }
      }
      validates :status, inclusion: {
        in: [ "active", "inactive", "archived" ],
        message: "%{value} is not a valid status"
      }
      validate :schedule_json_is_valid

      belongs_to :course_schedule, class_name: "Api::Course::CourseSchedule", foreign_key: "course_schedule_id", inverse_of: :course_schedule_overrides

      # Validation for presence of associated records
      validates :course_schedule, presence: true

      private
      def schedule_json_is_valid
        parsed = schedule_json || {}

        unless parsed.is_a?(Hash)
          begin
            parsed = JSON.parse(schedule_json)
          rescue JSON::ParserError
            errors.add(:schedule_json, "must be a valid JSON object") and return
          end
        end

        valid_days = [ "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" ]
        time_regex = /\A([01]\d|2[0-3]):([0-5]\d)\z/
        parsed.each do |day, periods|
          unless valid_days.include?(day.to_s.downcase)
            errors.add(:schedule_json, "contains invalid day: #{day}")
          end

          unless periods.is_a?(Array)
            errors.add(:schedule_json, "value for #{day} must be an array of time periods")
            next
          end

          periods.each_with_index do |period, index|
            unless period.is_a?(Hash) && period.key?("start") && period.key?("end")
              errors.add(:schedule_json, "period #{index + 1} for #{day} must be a hash with 'start' and 'end' keys")
              next
            end

            %w[start end].each do |key|
              unless period[key].is_a?(String) && period[key].match?(time_regex)
                errors.add(:schedule_json, "#{key} time in period #{index + 1} for #{day} must be a string in HH:MM format")
              end
            end
          end
        end
      end
    end
  end
end
