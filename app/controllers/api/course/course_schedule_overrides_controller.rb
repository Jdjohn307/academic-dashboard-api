module Api
  module Course
    class CourseScheduleOverridesController < BaseController
      before_action :authorize_request
      before_action :set_course_schedule_override, only: [ :show, :update, :destroy ]

      # GET /api/course/course_schedules_overrides
      def index
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(CourseScheduleOverride.all, permit_options)
      end

      # GET /api/course/course_schedules_overrides/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @course_schedule_override, status: :ok
      end

      # POST /api/course/course_schedules_overrides
      def create
        authorize_roles!("Administrator", "Teacher", "General Staff")
        course_schedule_override_record = CourseScheduleOverride.new(course_schedule_override_params)
        course_schedule_override_record.save!
        render jsonapi: course_schedule_override_record, status: :created
      end

      # PATCH/PUT /api/course/course_schedules_overrides/:id
      def update
        authorize_roles!("Administrator", "Teacher", "General Staff")
        @course_schedule_override.update!(course_schedule_override_params)
        render jsonapi: @course_schedule_override, status: :ok
      end

      # DELETE /api/course/course_schedules_overrides/:id
      def destroy
        authorize_roles!("Administrator", "Teacher", "General Staff")
        @course_schedule_override.destroy!
        head :no_content
      end

      private

      def set_course_schedule_override
        @course_schedule_override = CourseScheduleOverride.find(params[:id])
      end

      def course_schedule_override_params
        params.permit(:course_schedule_id, :override_date, :notes, :status, schedule_json: {})
      end
    end
  end
end
