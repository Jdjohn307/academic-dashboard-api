module Api
  module Course
    class SerializableCourse < JSONAPI::Serializable::Resource
      attributes :name, :semester, :year, :code, :status
    end
  end
end