module Api
  module Course
    class CourseController < BaseController
      def create
        course_record = Course.new(create_params)

        if course_record.save
          render jsonapi: course_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: course_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        course_record = Course.find_by(id: show_params["id"])

        render jsonapi: course_record, status: :ok
      end

      def index
        render jsonapi: Course.all, status: :ok
      end

      def update
        course_record = Course.find_by(id: update_params["id"])

        if course_record.blank?
          render json: { error: [ { title: "Not Found", detail: "Course with id: #{update_params[:id]} was not found." } ] }, status: :not_found
          return
        end

        if course_record.update(update_params)
          render jsonapi: course_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: course_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        course_record = Course.find_by(id: delete_params["id"])

        if course_record.blank?
          render json: { error: [ { title: "Not Found", detail: "Course with id: #{delete_params[:id]} was not found." } ] }, status: :not_found
          return
        end

        if course_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: course_record.errors } ] }, status: :unprocessable_entity
        end
      end
      private

      def create_params
        # params.require(:name, :semester, :year, :code)
        params.permit(:name, :semester, :year, :code, :status)
      end

      def show_params
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :name, :semester, :year, :code, :status)
      end

      def delete_params
        params.permit(:id)
      end
    end
  end
end
