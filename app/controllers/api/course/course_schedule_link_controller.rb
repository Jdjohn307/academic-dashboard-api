module Api
  module Course
    class CourseScheduleLinkController < BaseController
      def create
        course_schedule_link_record = CourseScheduleLink.new(create_params)

        if course_schedule_link_record.save
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        course_schedule_link_record = CourseScheduleLink.find_by(id: show_params[:id])
        
        render jsonapi: course_schedule_link_record, status: :ok
        return
      end

      def index
        render jsonapi: CourseScheduleLink.all, status: :ok
        return
      end

      def update
        course_schedule_link_record = CourseScheduleLink.find_by(id: update_params[:id])

        if course_schedule_link_record.blank?
          render jsonapi: { error: "Course Schedule Link not found" }, status: :not_found
          return
        end

        if course_schedule_link_record.update(update_params)
          render jsonapi: course_schedule_link_record, status: :created
          return
        else
          render jsonapi: { errors: course_schedule_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        course_schedule_link_record = CourseScheduleLink.find_by(id: delete_params[:id])

        if course_schedule_link_record.blank?
          render jsonapi: { error: "Course Schedule Link not found" }, status: :not_found
          return
        end

        if course_schedule_link_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: course_schedule_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:user_id, :course_schedule_id)
        params.permit(:user_id, :course_schedule_id, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :user_id, :course_schedule_id, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end