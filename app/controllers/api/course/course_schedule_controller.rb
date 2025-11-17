module Api
  module Course
    class CourseScheduleController < BaseController
      def create
        course_schedule_record = CourseSchedule.new(create_params)

        if course_schedule_record.save
          render jsonapi: course_schedule_record, status: :created
          nil
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
          nil
        end
      end

      def show
        course_schedule_record = CourseSchedule.find_by(id: show_params["id"])

        render jsonapi: course_schedule_record, status: :ok
        nil
      end

      def index
        render jsonapi: CourseSchedule.all, status: :ok
        nil
      end

      def update
        course_schedule_record = CourseSchedule.find_by(id: update_params["id"])

        if course_schedule_record.blank?
          render json: { error: [ { title: "Error", detail: "Course Schedule Not Found." } ] }, status: :unprocessable_entity
          return
        end

        if course_schedule_record.update(update_params)
          render jsonapi: course_schedule_record, status: :ok
          nil
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
          nil
        end
      end

      def destroy
        course_schedule_record = CourseSchedule.find_by(id: delete_params["id"])

        if course_schedule_record.blank?
          render json: { error: [ { title: "Error", detail: "Course Schedule Not Found." } ] }, status: :unprocessable_entity
          return
        end

        if course_schedule_record.destroy
          render json: {}, status: :no_content
          nil
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
          nil
        end
      end

      private

      def create_params
        # params.require(:name, :semester, :year, :code)
        params.permit(:name, :course_id, :start_date, :end_date, :schedule_json, :status)
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :name, :course_id, :start_date, :end_date, :schedule_json, :status)
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end
