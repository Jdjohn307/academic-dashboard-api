module Api
  module Course
    class SerializableCourse < JSONAPI::Serializable::Resource
      type "courses"
      attributes :name, :semester, :year, :code, :status
    end
  end
end
