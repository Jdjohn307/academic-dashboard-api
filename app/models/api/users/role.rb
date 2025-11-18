module Api
  module Users
    class Role < ApplicationRecord
      self.table_name = "role"

      # Validation
      validates :name, presence: true, length: { maximum: 100 }
      validates :status, inclusion: {
        in: [ "active", "inactive", "archived" ],
        message: "%{value} is not a valid status"
      }

      has_many :user_role_links, class_name: "Api::Users::UserRoleLink", foreign_key: "role_id", inverse_of: :role
    end
  end
end
