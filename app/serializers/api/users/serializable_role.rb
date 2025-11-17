module Api
  module Users
    class SerializableRole < JSONAPI::Serializable::Resource
      type "roles"
      attributes :name, :status
    end
  end
end
