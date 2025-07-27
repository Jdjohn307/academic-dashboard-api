module Api
  module Course
    class CourseScheduleOverrideController < BaseController
      def create
        course_schedule_override_record = CourseScheduleOverride.new(create_params)

        if course_schedule_override_record.save
          render jsonapi: course_schedule_override_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_override_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        course_schedule_override_record = CourseScheduleOverride.find_by(id: show_params[:id])
        
        render jsonapi: course_schedule_override_record, status: :ok
        return
      end

      def index
        render jsonapi: CourseScheduleOverride.all, status: :ok
        return
      end

      def update
        course_schedule_override_record = CourseScheduleOverride.find_by(id: update_params[:id])

        if course_schedule_override_record.blank?
          render jsonapi: { error: "Course Schedule Override not found" }, status: :not_found
          return
        end

        if course_schedule_override_record.update(update_params)
          render jsonapi: course_schedule_override_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_override_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        course_schedule_override_record = CourseScheduleOverride.find_by(id: delete_params[:id])

        if course_schedule_override_record.blank?
          render jsonapi: { error: "Course Schedule Override not found" }, status: :not_found
          return
        end

        if course_schedule_override_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: course_schedule_override_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:course_schedule_id, :override_date, :schedule_json)
        params.permit(:course_schedule_id, :override_date, :schedule_json, :notes, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :course_schedule_id, :override_date, :schedule_json, :notes, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end