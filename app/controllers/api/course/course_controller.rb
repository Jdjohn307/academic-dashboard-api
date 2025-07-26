module Api
  module Course
    class CourseController < BaseController
      def create
        course_record = Course.new(create_params)

        if course_record.save
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: course_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        course_record = Course.find_by(id: show_params[:id])
        
        render jsonapi: course_record, status: :ok
        return
      end

      def index
        render jsonapi: Course.all, status: :ok
        return
      end

      def update
        course_record = Course.find_by(id: update_params[:id])

        if course_record.blank?
          render jsonapi: { error: "Course not found" }, status: :not_found
          return
        end

        if course_record.update(update_params)
          render jsonapi: course_record, status: :created
          return
        else
          render jsonapi: { errors: course_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        course_record = Course.find_by(id: delete_params[:id])

        if course_record.blank?
          render jsonapi: { error: "Course not found" }, status: :not_found
          return
        end

        if course_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: course_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:name, :semester, :year, :code)
        params.permit(:name, :semester, :year, :code, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :name, :semester, :year, :code, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end