module Api
  module Users
    class UserRoleLinkController < BaseController
      def create
        user_role_link_record = UserRoleLink.new(create_params)

        if user_role_link_record.save
          render jsonapi: user_role_link_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: user_role_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        user_role_link_record = UserRoleLink.find_by(id: show_params["id"])

        render jsonapi: user_role_link_record, status: :ok
      end

      def index
        render jsonapi: UserRoleLink.all, status: :ok
      end

      def update
        user_role_link_record = UserRoleLink.find_by(id: update_params["id"])

        if user_role_link_record.blank?
          render json: { error: [ { title: "Error", detail: "User Role Link Not Found." } ] }, status: :not_found
          return
        end

        if user_role_link_record.update(update_params)
          render jsonapi: user_role_link_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: user_role_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        user_role_link_record = UserRoleLink.find_by(id: delete_params["id"])

        if user_role_link_record.blank?
          render json: { error: [ { title: "Error", detail: "User Role Link Not Found." } ] }, status: :not_found
          return
        end

        if user_role_link_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: user_role_link_record.errors } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        params.permit(:user_id, :role_id, :status)
      end

      def show_params
        params.permit(:id)
      end

      def update_params
        params.permit(:id, :user_id, :role_id, :status)
      end

      def delete_params
        params.permit(:id)
      end
    end
  end
end
