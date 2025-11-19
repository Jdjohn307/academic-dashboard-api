module Api
  module Course
    class CourseSchedulesController < BaseController
      before_action :set_course_schedule, only: [ :show, :update, :destroy ]

      # GET /api/course/course_schedules
      def index
        render jsonapi: CourseSchedule.all, status: :ok
      end

      # GET /api/course/course_schedules/:id
      def show
        render jsonapi: @course_schedule, status: :ok
      end

      # POST /api/course/course_schedules
      def create
        course_schedule_record = CourseSchedule.new(course_schedule_params)
        if course_schedule_record.save
          render jsonapi: course_schedule_record, status: :created
        else
          render json: { errors: course_schedule_record.errors.full_messages.map { |msg| { title: "Invalid Data", detail: msg, status: "unprocessable_entity" } } }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/course/course_schedules/:id
      def update
        @course_schedule.update!(course_schedule_params)
        render jsonapi: @course_schedule, status: :ok
      end

      # DELETE /api/course/course_schedules/:id
      def destroy
        @course_schedule.destroy!
        head :no_content
      end

      private

      def set_course_schedule
        @course_schedule = CourseSchedule.find(params[:id])
      end

      def course_schedule_params
        params.permit(:name, :course_id, :start_date, :end_date, :schedule_json, :status)
      end
    end
  end
end
