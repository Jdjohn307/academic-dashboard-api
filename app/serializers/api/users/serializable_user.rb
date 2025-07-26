module Api
  module Users
    class SerializableUser < JSONAPI::Serializable::Resource
      attributes :name, :email, :encrypted_password, :status
    end
  end
end