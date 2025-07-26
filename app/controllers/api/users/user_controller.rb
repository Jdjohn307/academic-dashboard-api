module Api
  module Users
    class UserController < BaseController
      def create
        user_record = User.new(create_params)

        if user_record.save
          render jsonapi: user_record, status: :created
          return
        else
          render jsonapi: { errors: user_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def show
        user_record = User.find_by(id: show_params[:id])
        
        render jsonapi: user_record, status: :ok
        return
      end

      def index
        render jsonapi: User.all, status: :ok
        return
      end

      def update
        user_record = User.find_by(id: update_params[:id])

        if user_record.blank?
          render jsonapi: { error: "User not found" }, status: :not_found
          return
        end

        if user_record.update(update_params)
          render jsonapi: user_record, status: :created
          return
        else
          render jsonapi: { errors: user_record.errors}, status: :unprocessable_entity
          return
        end
      end

      def delete
        user_record = User.find_by(id: delete_params[:id])

        if user_record.blank?
          render jsonapi: { error: "User not found" }, status: :not_found
          return
        end

        if user_record.destroy
          render jsonapi: {}, status: :no_content
          return
        else
          render jsonapi: { errors: user_record.errors}, status: :unprocessable_entity
          return
        end
      end

      private

      def create_params
        params.require(:name, :email, :encrypted_password)
        params.permit(:name, :email, :encrypted_password, :status)
      end

      def show_params
        params.require(:id)
      end

      def update_params
        params.require(:id)
        params.permit(:id, :name, :email, :encrypted_password, :status)
      end

      def delete_params
        params.require(:id)
      end
    end
  end
end