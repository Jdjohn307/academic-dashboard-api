module Api
  module Assignment
    class AssignmentGradeLinksController < BaseController
      before_action :set_assignment_grade_link, only: [ :show, :update, :destroy ]

      # GET /api/assignment/assignment_grade_links
      def index
        render jsonapi: AssignmentGradeLink.all, status: :ok
      end

      # GET /api/assignment/assignment_grade_links/:id
      def show
        render jsonapi: @assignment_grade_link, status: :ok
      end

      # POST /api/assignment/assignment_grade_links
      def create
        assignment_grade_link = AssignmentGradeLink.new(assignment_grade_link_params)
        assignment_grade_link.save!
        render jsonapi: assignment_grade_link, status: :created
      end

      # PATCH/PUT /api/assignment/assignment_grade_links/:id
      def update
        @assignment_grade_link.update!(assignment_grade_link_params)
        render jsonapi: @assignment_grade_link, status: :ok
      end

      # DELETE /api/assignment/assignment_grade_links/:id
      def destroy
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
