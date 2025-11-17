module Api
  module Users
    class UserRoleLink < ApplicationRecord
      self.table_name = "user_role_link"

      belongs_to :user, class_name: "Api::Users::User", foreign_key: "user_id", required: true, inverse_of: :user_role_links
      belongs_to :role, class_name: "Api::Users::Role", foreign_key: "role_id", required: true, inverse_of: :user_role_links
    end
  end
end
