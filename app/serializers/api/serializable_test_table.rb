module Api
  class SerializableTestTable < JSONAPI::Serializable::Resource
    attributes :name
  end
end