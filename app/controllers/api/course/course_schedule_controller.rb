module Api
  module Course
    class CourseScheduleController < BaseController
      def create
        course_schedule_record = CourseSchedule.new(create_params)

        if course_schedule_record.save
          render jsonapi: course_schedule_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        course_schedule_record = CourseSchedule.find_by(id: show_params["id"])

        render jsonapi: course_schedule_record, status: :ok
      end

      def index
        render jsonapi: CourseSchedule.all, status: :ok
      end

      def update
        course_schedule_record = CourseSchedule.find_by(id: update_params["id"])

        if course_schedule_record.blank?
          render json: { error: [ { title: "Error", detail: "Course Schedule Not Found." } ] }, status: :unprocessable_entity
          return
        end

        if course_schedule_record.update(update_params)
          render jsonapi: course_schedule_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
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
        else
          render json: { error: [ { title: "Error", detail: course_schedule_record.errors } ] }, status: :unprocessable_entity
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
