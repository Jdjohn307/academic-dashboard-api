module Api
  module Course
    class CourseScheduleOverrideController < BaseController
      def create
        course_schedule_override_record = CourseScheduleOverride.new(create_params)

        if course_schedule_override_record.save
          render jsonapi: course_schedule_override_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: course_schedule_override_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        course_schedule_override_record = CourseScheduleOverride.find_by(id: show_params["id"])

        render jsonapi: course_schedule_override_record, status: :ok
      end

      def index
        render jsonapi: CourseScheduleOverride.all, status: :ok
      end

      def update
        course_schedule_override_record = CourseScheduleOverride.find_by(id: update_params["id"])

        if course_schedule_override_record.blank?
          render json: { error: [ { title: "Error", detail: "Course Schedule Override Not Found." } ] }, status: :not_found
          return
        end

        if course_schedule_override_record.update(update_params)
          render jsonapi: course_schedule_override_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: course_schedule_override_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        course_schedule_override_record = CourseScheduleOverride.find_by(id: delete_params["id"])

        if course_schedule_override_record.blank?
          render json: { error: [ { title: "Error", detail: "Course Schedule Override Not Found." } ] }, status: :not_found
          return
        end

        if course_schedule_override_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: course_schedule_override_record.errors } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        # params.require(:course_schedule_id, :override_date, :schedule_json)
        params.permit(:course_schedule_id, :override_date, :notes, :status, schedule_json: {})
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :course_schedule_id, :override_date, :notes, :status, schedule_json: {})
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end
