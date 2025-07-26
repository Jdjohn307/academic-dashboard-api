module Api
  module Users
    class RoleController < BaseController
      def create
        role_record = Role.new(create_params)

        if role_record.save
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: role_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        role_record = Role.find_by(id: show_params[:id])
        
        render jsonapi: role_record, status: :ok
        return
      end

      def index
        render jsonapi: Role.all, status: :ok
        return
      end

      def update
        role_record = Role.find_by(id: update_params[:id])

        if role_record.blank?
          render jsonapi: { error: "User not found" }, status: :not_found
          return
        end

        if role_record.update(update_params)
          render jsonapi: role_record, status: :created
          return
        else
          render jsonapi: { errors: role_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        role_record = Role.find_by(id: delete_params[:id])

        if role_record.blank?
          render jsonapi: { error: "Role not found" }, status: :not_found
          return
        end

        if role_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: role_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:name)
        params.permit(:name, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :name, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end