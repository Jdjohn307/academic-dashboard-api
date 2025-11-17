module Api
  module Users
    class GradeController < BaseController
      def create
        grade_record = Grade.new(create_params)

        if grade_record.save
          render jsonapi: grade_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: grade_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        grade_record = Grade.find_by(id: show_params["id"])

        render jsonapi: grade_record, status: :ok
      end

      def index
        render jsonapi: Grade.all, status: :ok
      end

      def update
        grade_record = Grade.find_by(id: update_params["id"])

        if grade_record.blank?
          render json: { error: [ { title: "Error", detail: "Grade Not Found." } ] }, status: :not_found
          return
        end

        if grade_record.update(update_params)
          render jsonapi: grade_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: grade_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        grade_record = Grade.find_by(id: delete_params["id"])

        if grade_record.blank?
          render json: { error: [ { title: "Error", detail: "Grade Not Found." } ] }, status: :not_found
          return
        end

        if grade_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: grade_record.errors } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        # params.require(:user_id, :course_id)
        params.permit(:user_id, :course_id, :final_grade, :comments, :status)
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :user_id, :course_id, :final_grade, :comments, :status)
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end
