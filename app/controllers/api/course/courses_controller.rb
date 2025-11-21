module Api
  module Course
    class CoursesController < BaseController
      before_action :set_course, only: [ :show, :update, :destroy ]

      # GET /api/course/courses
      def index
        render_paginated(Course.all, permit_options[:options] || {})
      end

      # GET /api/course/courses/:id
      def show
        render jsonapi: @course, status: :ok
      end

      # POST /api/course/courses
      def create
        course_record = Course.new(course_params)
        if course_record.save
          render jsonapi: course_record, status: :created
        else
          render json: { errors: course_record.errors.full_messages.map { |msg| { title: "Invalid Data", detail: msg, status: "unprocessable_entity" } } }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/course/courses/:id
      def update
        @course.update!(course_params)
        render jsonapi: @course, status: :ok
      end

      # DELETE /api/course/courses/:id
      def destroy
        @course.destroy!
        head :no_content
      end

      private

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.permit(:name, :semester, :year, :code, :status)
      end
    end
  end
end
