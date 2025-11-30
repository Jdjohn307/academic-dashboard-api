module Api
  module Users
    class GradesController < BaseController
      before_action :authorize_request
      before_action :set_grade, only: [ :show, :update, :destroy ]

      # GET /api/users/grades
      def index # TODO: Update this and tests to have less access than show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(Grade.all, permit_options)
      end

      # GET /api/users/grades/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @grade, status: :ok
      end

      # POST /api/users/grades
      def create
        authorize_roles!("Administrator", "Teacher")
        grade_record = Grade.new(grade_params)
        grade_record.save!
        render jsonapi: grade_record, status: :created
      end

      # PATCH/PUT /api/users/grades/:id
      def update
        authorize_roles!("Administrator", "Teacher")
        @grade.update!(grade_params)
        render jsonapi: @grade, status: :ok
      end

      # DELETE /api/users/grades/:id
      def destroy
        authorize_roles!("Administrator", "Teacher")
        @grade.destroy!
        head :no_content
      end

      private

      def set_grade
        @grade = Grade.find(params[:id])
      end

      def grade_params
        params.permit(:user_id, :course_id, :final_grade, :comments, :status)
      end
    end
  end
end
