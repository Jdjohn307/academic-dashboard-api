module Api
  module Users
    class SerializableUser < JSONAPI::Serializable::Resource
      type "users"
      attributes :name, :email, :status
    end
  end
end
