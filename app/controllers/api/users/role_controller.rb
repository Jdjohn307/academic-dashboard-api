module Api
  module Users
    class RoleController < BaseController
      def create
        role_record = Role.new(create_params)

        if role_record.save
          render jsonapi: role_record, status: :created
        else
          render json: { error: [ { title: "Error", detail: role_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def show
        role_record = Role.find_by(id: show_params["id"])

        render jsonapi: role_record, status: :ok
      end

      def index
        render jsonapi: Role.all, status: :ok
      end

      def update
        role_record = Role.find_by(id: update_params["id"])

        if role_record.blank?
          render json: { error: [ { title: "Error", detail: "Role Not Found." } ] }, status: :not_found
          return
        end

        if role_record.update(update_params)
          render jsonapi: role_record, status: :ok
        else
          render json: { error: [ { title: "Error", detail: role_record.errors } ] }, status: :unprocessable_entity
        end
      end

      def destroy
        role_record = Role.find_by(id: delete_params["id"])

        if role_record.blank?
          render json: { error: [ { title: "Error", detail: "Role Not Found." } ] }, status: :not_found
          return
        end

        if role_record.destroy
          render json: {}, status: :no_content
        else
          render json: { error: [ { title: "Error", detail: role_record.errors } ] }, status: :unprocessable_entity
        end
      end

      private

      def create_params
        # params.require(:name)
        params.permit(:name, :status)
      end

      def show_params
        # params.require(:id)
        params.permit(:id)
      end

      def update_params
        # params.require(:id)
        params.permit(:id, :name, :status)
      end

      def delete_params
        # params.require(:id)
        params.permit(:id)
      end
    end
  end
end
