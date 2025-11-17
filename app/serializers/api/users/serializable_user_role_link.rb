module Api
  module Users
    class SerializableUserRoleLink < JSONAPI::Serializable::Resource
      attributes :user_id, :role_id, :status
    end
  end
end
