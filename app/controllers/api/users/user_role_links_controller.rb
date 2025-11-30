module Api
  module Users
    class UserRoleLinksController < BaseController
      before_action :authorize_request
      before_action :set_user_role_link, only: [ :show, :update, :destroy ]

      # GET /api/users/user_role_links
      def index # TODO: Update this and tests to have less access than show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render_paginated(UserRoleLink.all, permit_options)
      end

      # GET /api/users/user_role_links/:id
      def show
        authorize_roles!("Administrator", "Teacher", "Teaching Assistant", "Student", "General Staff")
        render jsonapi: @user_role_link, status: :ok
      end

      # POST /api/users/user_role_links
      def create
        authorize_roles!("Administrator")
        user_role_link_record = UserRoleLink.new(user_role_link_params)
        if user_role_link_record.save
          render jsonapi: user_role_link_record, status: :created
        else
          render json: { errors: user_role_link_record.errors.full_messages.map { |msg| { title: "Invalid Data", detail: msg, status: "unprocessable_entity" } } }, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/users/user_role_links/:id
      def update
        authorize_roles!("Administrator")
        @user_role_link.update!(user_role_link_params)
        render jsonapi: @user_role_link, status: :ok
      end

      # DELETE /api/users/user_role_links/:id
      def destroy
        authorize_roles!("Administrator")
        @user_role_link.destroy!
        head :no_content
      end

      private

      def set_user_role_link
        @user_role_link = UserRoleLink.find(params[:id])
      end

      def user_role_link_params
        params.permit(:user_id, :role_id, :status)
      end
    end
  end
end
