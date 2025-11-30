module Api
  module Users
    class UsersController < BaseController
      before_action :authorize_request
      before_action :set_user_record, only: [ :show, :update, :destroy ]

      # GET /api/users/users
      def index
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(User.all, permit_options)
      end

      # GET /api/users/users/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @user_record, status: :ok
      end

      # POST /api/users/users
      def create
        authorize_roles!("Administrator")
        user_record = User.new(user_params)
        user_record.save!
        render jsonapi: user_record, status: :created
      end

      # PATCH/PUT /api/users/users/:id
      def update
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        @user_record.update!(user_params)
        render jsonapi: @user_record, status: :ok
      end

      # DELETE /api/users/users/:id
      def destroy
        authorize_roles!("Administrator")
        @user_record.destroy!
        head :no_content
      end

      private

      def user_params
       params.permit(:name, :email, :password, :password_confirmation, :status)
      end

      def set_user_record
        @user_record = User.find(params[:id])
      end
    end
  end
end
