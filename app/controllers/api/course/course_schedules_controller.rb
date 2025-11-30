module Api
  module Course
    class CourseSchedulesController < BaseController
      before_action :authorize_request
      before_action :set_course_schedule, only: [ :show, :update, :destroy ]

      # GET /api/course/course_schedules
      def index
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(CourseSchedule.all, permit_options)
      end

      # GET /api/course/course_schedules/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @course_schedule, status: :ok
      end

      # POST /api/course/course_schedules
      def create
        authorize_roles!("Administrator", "Teacher", "General Staff")
        course_schedule_record = CourseSchedule.new(course_schedule_params)
        if course_schedule_record.save
          render jsonapi: course_schedule_record, status: :created
        else
          render_unprocessable_entity(course_schedule_record)
        end
      end

      # PATCH/PUT /api/course/course_schedules/:id
      def update
        authorize_roles!("Administrator", "Teacher", "General Staff")
        @course_schedule.update!(course_schedule_params)
        render jsonapi: @course_schedule, status: :ok
      end

      # DELETE /api/course/course_schedules/:id
      def destroy
        authorize_roles!("Administrator", "Teacher", "General Staff")
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
