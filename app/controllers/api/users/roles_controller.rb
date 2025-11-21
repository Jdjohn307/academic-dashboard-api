module Api
  module Users
    class RolesController < BaseController
      before_action :set_role, only: [ :show, :update, :destroy ]

      # GET /api/users/roles
      def index
        render_paginated(Role.all, permit_options[:options] || {})
      end

      # GET /api/users/roles/:id
      def show
        render jsonapi: @role, status: :ok
      end

      # POST /api/users/roles
      def create
        role_record = Role.new(role_params)
        if role_record.save
          render jsonapi: role_record, status: :created
        else
          render json: { errors: role_record.errors.full_messages.map { |msg| { title: "Invalid Data", detail: msg, status: "unprocessable_entity" } } }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/users/roles/:id
      def update
        @role.update!(role_params)
        render jsonapi: @role, status: :ok
      end

      # DELETE /api/users/roles/:id
      def destroy
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
