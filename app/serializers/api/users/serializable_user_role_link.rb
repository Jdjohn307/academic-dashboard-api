module Api
  module Users
    class SerializableUserRoleLink < JSONAPI::Serializable::Resource
      type "user_role_links"
      attributes :user_id, :role_id, :status
    end
  end
end
