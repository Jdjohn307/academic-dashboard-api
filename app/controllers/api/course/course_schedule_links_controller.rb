module Api
  module Course
    class CourseScheduleLinksController < BaseController
      before_action :authorize_request
      before_action :set_course_schedule_link, only: [ :show, :update, :destroy ]

      # GET /api/course/course_schedules_links
      def index
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(CourseScheduleLink.all, permit_options)
      end

      # GET /api/course/course_schedules_links/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @course_schedule_link, status: :ok
      end

      # POST /api/course/course_schedules_links
      def create
        authorize_roles!("Administrator", "Teacher", "General Staff")
        course_schedule_link_record = CourseScheduleLink.new(course_schedule_link_params)
        if course_schedule_link_record.save
          render jsonapi: course_schedule_link_record, status: :created
        else
          render json: { errors: course_schedule_link_record.errors.full_messages.map { |msg| { title: "Invalid Data", detail: msg, status: "unprocessable_entity" } } }, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/course/course_schedules_links/:id
      def update
        authorize_roles!("Administrator", "Teacher", "Student", "General Staff")
        @course_schedule_link.update!(course_schedule_link_params)
        render jsonapi: @course_schedule_link, status: :ok
      end

      # DELETE /api/course/course_schedules_links/:id
      def destroy
        authorize_roles!("Administrator", "Teacher", "General Staff")
        @course_schedule_link.destroy!
        head :no_content
      end

      private

      def set_course_schedule_link
        @course_schedule_link = CourseScheduleLink.find(params[:id])
      end

      def course_schedule_link_params
        params.permit(:user_id, :course_schedule_id, :status)
      end
    end
  end
end
