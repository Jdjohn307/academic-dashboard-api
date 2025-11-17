module Api
  module Users
    class SerializableUser < JSONAPI::Serializable::Resource
      type "users"
      attributes :name, :email, :encrypted_password, :status
    end
  end
end
