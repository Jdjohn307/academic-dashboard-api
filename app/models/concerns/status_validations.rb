# app/models/concerns/status_validations.rb
module StatusValidations
  ASSIGNMENT_GRADE_LINK_STATUSES = [ "active", "inactive", "submitted", "graded", "archived" ].freeze
  ASSIGNMENT_STATUSES = [ "active", "inactive", "draft", "published", "archived" ].freeze
  COURSE_SCHEDULE_LINK_STATUSES = [ "active", "inactive", "completed", "hold", "archived" ].freeze
  COURSE_SCHEDULE_OVERRIDE_STATUSES = [ "active", "inactive", "archived" ].freeze
  COURSE_SCHEDULE_STATUSES = [ "active", "complete", "hold", "archived" ].freeze
  COURSE_STATUSES = [ "active", "inactive", "archived" ].freeze
  GRADE_STATUSES = [ "active", "inactive", "posted", "archived" ].freeze
  ROLE_STATUSES = [ "active", "inactive", "archived" ].freeze
  USER_ROLE_LINK_STATUSES = [ "active", "inactive", "archived" ].freeze
  USER_STATUSES = [ "active", "inactive", "archived" ].freeze
end
