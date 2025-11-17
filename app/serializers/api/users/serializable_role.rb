module Api
  module Users
    class SerializableRole < JSONAPI::Serializable::Resource
      attributes :name, :status
    end
  end
end
