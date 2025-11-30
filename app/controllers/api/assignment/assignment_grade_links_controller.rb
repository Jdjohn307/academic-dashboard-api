module Api
  module Assignment
    class AssignmentGradeLinksController < BaseController
      before_action :authorize_request
      before_action :set_assignment_grade_link, only: [ :show, :update, :destroy ]

      # GET /api/assignment/assignment_grade_links
      def index
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(AssignmentGradeLink.all, permit_options)
      end

      # GET /api/assignment/assignment_grade_links/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @assignment_grade_link, status: :ok
      end

      # POST /api/assignment/assignment_grade_links
      def create
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant")
        assignment_grade_link = AssignmentGradeLink.new(assignment_grade_link_params)
        assignment_grade_link.save!
        render jsonapi: assignment_grade_link, status: :created
      end

      # PATCH/PUT /api/assignment/assignment_grade_links/:id
      def update
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant")
        @assignment_grade_link.update!(assignment_grade_link_params)
        render jsonapi: @assignment_grade_link, status: :ok
      end

      # DELETE /api/assignment/assignment_grade_links/:id
      def destroy
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant")
        @assignment_grade_link.destroy!
        head :no_content
      end

      private

      def set_assignment_grade_link
        @assignment_grade_link = AssignmentGradeLink.find(params[:id])
      end

      def assignment_grade_link_params
        params.permit(:grade_id, :assignment_id, :submitted_at, :graded_at, :grade, :points, :feedback, :status)
      end
    end
  end
end
