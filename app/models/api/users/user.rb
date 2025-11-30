module Api
  module Users
    class User < ApplicationRecord
      self.table_name = "user"

      has_secure_password

      # Validation
      validates :name, presence: true, length: { maximum: 100 }
      validates :email, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :password,
        length: { minimum: 12, maximum: 72 },
        format: {
          with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
          message: "must include uppercase, lowercase, and number"
        },
        if: :password_digest_changed?
      validates :status, inclusion: {
        in: USER_STATUSES,
        message: "%{value} is not a valid status"
      }

      # Relationships
      has_many :user_role_links, class_name: "Api::Users::UserRoleLink", foreign_key: "user_id", inverse_of: :user
      has_many :grades, class_name: "Api::Users::Grade", foreign_key: "user_id", inverse_of: :user
      has_many :course_schedule_links, class_name: "Api::Course::CourseScheduleLink", foreign_key: "user_id", inverse_of: :user
    end
  end
end
