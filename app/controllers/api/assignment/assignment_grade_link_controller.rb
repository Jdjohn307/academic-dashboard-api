module Api
  module Assignment
    class AssignmentGradeLinkController < BaseController
      def create
        assignment_grade_link_record = AssignmentGradeLink.new(create_params)

        if assignment_grade_link_record.save
          render jsonapi: assignment_grade_link_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: assignment_grade_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        assignment_grade_link_record = AssignmentGradeLink.find_by(id: show_params["id"])

        render jsonapi: assignment_grade_link_record, status: :ok
      end

      def index
        render jsonapi: AssignmentGradeLink.all, status: :ok
      end

      def update
        assignment_grade_link_record = AssignmentGradeLink.find_by(id: update_params["id"])

        if assignment_grade_link_record.blank?
          render json: { error: [ { title: "Error", detail: "Assignment Grade Link Not Found." } ] }, status: :not_found
          return
        end

        if assignment_grade_link_record.update(update_params)
          render jsonapi: assignment_grade_link_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: assignment_grade_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        assignment_grade_link_record = AssignmentGradeLink.find_by(id: delete_params["id"])

        if assignment_grade_link_record.blank?
          render json: { error: [ { title: "Error", detail: "Assignment Grade Link Not Found." } ] }, status: :not_found
          return
        end

        if assignment_grade_link_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: assignment_grade_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        # params.require(:grade_id, :assignment_id, :submitted_at)
        params.permit(:grade_id, :assignment_id, :submitted_at, :graded_at, :grade, :points, :feedback, :status)
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :grade_id, :assignment_id, :submitted_at, :graded_at, :grade, :points, :feedback, :status)
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end
