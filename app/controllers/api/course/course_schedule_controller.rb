module Api
  module Course
    class CourseScheduleController < BaseController
      def create
        course_schedule_record = CourseSchedule.new(create_params)

        if course_schedule_record.save
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        course_schedule_record = CourseSchedule.find_by(id: show_params[:id])
        
        render jsonapi: course_schedule_record, status: :ok
        return
      end

      def index
        render jsonapi: CourseSchedule.all, status: :ok
        return
      end

      def update
        course_schedule_record = CourseSchedule.find_by(id: update_params[:id])

        if course_schedule_record.blank?
          render jsonapi: { error: "Course Schedule not found" }, status: :not_found
          return
        end

        if course_schedule_record.update(update_params)
          render jsonapi: course_schedule_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        course_schedule_record = CourseSchedule.find_by(id: delete_params[:id])

        if course_schedule_record.blank?
          render jsonapi: { error: "Course Schedule not found" }, status: :not_found
          return
        end

        if course_schedule_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: course_schedule_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:name, :semester, :year, :code)
        params.permit(:name, :course_id, :start_date, :end_date, :schedule_json, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :name, :course_id, :start_date, :end_date, :schedule_json, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end