module Api
  module Assignment
    class AssignmentGradeLinkController < BaseController
      def create
        assignment_grade_link_record = AssignmentGradeLink.new(create_params)

        if assignment_grade_link_record.save
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: assignment_grade_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        assignment_grade_link_record = AssignmentGradeLink.find_by(id: show_params[:id])
        
        render jsonapi: assignment_grade_link_record, status: :ok
        return
      end

      def index
        render jsonapi: AssignmentGradeLink.all, status: :ok
        return
      end

      def update
        assignment_grade_link_record = AssignmentGradeLink.find_by(id: update_params[:id])

        if assignment_grade_link_record.blank?
          render jsonapi: { error: "Assignment Grade Link not found" }, status: :not_found
          return
        end

        if assignment_grade_link_record.update(update_params)
          render jsonapi: assignment_grade_link_record, status: :created
          return
        else
          render jsonapi: { errors: assignment_grade_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        assignment_grade_link_record = Assignment.find_by(id: delete_params[:id])

        if assignment_grade_link_record.blank?
          render jsonapi: { error: "Assignment Grade Link not found" }, status: :not_found
          return
        end

        if assignment_grade_link_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: assignment_grade_link_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:grade_id, :assignment_id, :submitted_at)
        params.permit(:grade_id, :assignment_id, :submitted_at, :graded_at, :grade, :points, :feedback, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :grade_id, :assignment_id, :submitted_at, :graded_at, :grade, :points, :feedback, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end