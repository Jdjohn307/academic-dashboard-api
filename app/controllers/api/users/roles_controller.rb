module Api
  module Users
    class RolesController < BaseController
      before_action :authorize_request
      before_action :set_role, only: [ :show, :update, :destroy ]

      # GET /api/users/roles
      def index
        authorize_roles!("Administrator")
        render_paginated(Role.all, permit_options)
      end

      # GET /api/users/roles/:id
      def show
        authorize_roles!("Administrator")
        render jsonapi: @role, status: :ok
      end

      # POST /api/users/roles
      def create
        authorize_roles!("Administrator")
        role_record = Role.new(role_params)
        if role_record.save
          render jsonapi: role_record, status: :created
        else
          render_unprocessable_entity(role_record)
        end
      end

      # PATCH/PUT /api/users/roles/:id
      def update
        authorize_roles!("Administrator")
        @role.update!(role_params)
        render jsonapi: @role, status: :ok
      end

      # DELETE /api/users/roles/:id
      def destroy
        authorize_roles!("Administrator")
        @role.destroy!
        head :no_content
      end

      private

      def set_role
        @role = Role.find(params[:id])
      end

      def role_params
        params.permit(:name, :status)
      end
    end
  end
end
