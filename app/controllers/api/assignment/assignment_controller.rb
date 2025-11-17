module Api
  module Assignment
    class AssignmentController < BaseController
      before_action :set_assignment_record, only: %i[show update destroy]

      def create
        assignment_record = Assignment.new(create_params)

        if assignment_record.save
          render jsonapi: assignment_record, status: :created
        else
          render json: { errors: [ { title: "Unprocessable Entity", detail: assignment_record.errors, status: :unprocessable_entity } ] }, status: :unprocessable_entity
        end
      end

      def show
        if @assignment_record.blank?
          render json: { errors: [ { title: "Not Found", detail: "Assignment Not Found.", status: :not_found } ] }, status: :not_found
          return
        end

        render jsonapi: @assignment_record, status: :ok
      end

      # Todo: add pagination, filtering, and ordering
      def index
        assignments = Assignment.all
        render jsonapi: assignments, status: :ok
      end

      def update
        if @assignment_record.blank?
          render json: { errors: [ { title: "Not Found", detail: "Assignment Not Found.", status: :not_found } ] }, status: :not_found
          return
        end

        if @assignment_record.update(update_params)
          render jsonapi: @assignment_record, status: :ok
        else
          render json: { errors: [ { title: "Unprocessable Entity", detail: @assignment_record.errors, status: :unprocessable_entity } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        if @assignment_record.blank?
          render json: { errors: [ { title: "Not Found", detail: "Assignment Not Found.", status: :not_found } ] }, status: :not_found
          return
        end

        if @assignment_record.destroy
          render json: {}, status: :no_content
        else
          render json: { errors: [ { title: "Unprocessable Entity", detail: @assignment_record.errors, status: :unprocessable_entity } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        params.permit(:course_schedule_id, :due_date, :title, :description, :points_possible, :status)
      end

      def update_params
        params.permit(:course_schedule_id, :due_date, :title, :description, :points_possible, :status)
      end

      def set_assignment_record
        @assignment_record = Assignment.find_by(id: params[:id])
      end
    end
  end
end
