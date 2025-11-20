module Api
  module Assignment
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [ :show, :update, :destroy ]

      # GET /api/assignment/assignments
      def index
        render_paginated(Assignment.all, permit_options[:options] || {})
      end

      # GET /api/assignment/assignments/:id
      def show
        render jsonapi: @assignment, status: :ok
      end

      # POST /api/assignment/assignments
      def create
        assignment = Assignment.new(assignment_params)
        assignment.save!
        render jsonapi: assignment, status: :created
      end

      # PATCH/PUT /api/assignment/assignments/:id
      def update
        @assignment.update!(assignment_params)
        render jsonapi: @assignment, status: :ok
      end

      # DELETE /api/assignment/assignments/:id
      def destroy
        @assignment.destroy!
        head :no_content
      end

      private

      def set_assignment
        @assignment = Assignment.find(params[:id])
      end

      def assignment_params
        params.permit(:course_schedule_id, :due_date, :title, :description, :points_possible, :status)
      end
    end
  end
end
