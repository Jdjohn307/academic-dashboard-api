module Api
  module Users
    class UsersController < BaseController
      before_action :set_user_record, only: [ :show, :update, :destroy ]

      # GET /api/users/users
      def index
        users = User.all
        render jsonapi: users, status: :ok
      end

      # GET /api/users/users/:id
      def show
        render jsonapi: @user_record, status: :ok
      end

      # POST /api/users/users
      def create
        user_record = User.new(user_params)
        user_record.save!
        render jsonapi: user_record, status: :created
      end

      # PATCH/PUT /api/users/users/:id
      def update
        @user_record.update!(user_params)
        render jsonapi: @user_record, status: :ok
      end

      # DELETE /api/users/users/:id
      def destroy
        @user_record.destroy!
        head :no_content
      end

      private

      def user_params
        params.permit(:name, :email, :encrypted_password, :status)
      end

      def set_user_record
        @user_record = User.find(params[:id])
      end
    end
  end
end
