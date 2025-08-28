module Api
  module Assignment
    class AssignmentController < BaseController
      def create
        assignment_record = Assignment.new(create_params)

        if assignment_record.save
          render jsonapi: assignment_record, status: :created
          return
        else
          render json: {error: [{ title: 'Error', detail: assignment_record.errors }] }, status: :unprocessable_entity
          return
        end
      end

      def show
        assignment_record = Assignment.find_by(id: show_params['id'])
        
        render jsonapi: assignment_record, status: :ok
        return
      end

      def index
        render jsonapi: Assignment.all, status: :ok
        return
      end

      def update
        assignment_record = Assignment.find_by(id: update_params['id'])

        if assignment_record.blank?
          render json: {error: [{ title: 'Error', detail: "Assignment Not Found." }] }, status: :not_found
          return
        end

        if assignment_record.update(update_params)
          render jsonapi: assignment_record, status: :ok
          return
        else
          render json: {error: [{ title: 'Error', detail: assignment_record.errors }] }, status: :unprocessable_entity
          return
        end
      end

      def destroy
        assignment_record = Assignment.find_by(id: delete_params['id'])

        if assignment_record.blank?
          render json: {error: [{ title: 'Error', detail: "Assignment Not Found." }] }, status: :not_found
          return
        end

        if assignment_record.destroy
          render json: {}, status: :no_content
          return
        else
          render json: {error: [{ title: 'Error', detail: assignment_record.errors }] }, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        # params.require(:course_schedule_id, :points_possible)
        params.permit(:course_schedule_id, :due_date, :title, :description, :points_possible, :status)
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :course_schedule_id, :due_date, :title, :description, :points_possible, :status)
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end