module Api
  module Users
    class Role < ApplicationRecord
      self.table_name = 'role'

      has_many :user_role_links, class_name: 'Api::Users::UserRoleLink', foreign_key: 'role_id', inverse_of: :role
    end
  end
end