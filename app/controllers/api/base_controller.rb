module Api
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session

     rescue_from ActiveRecord::NotNullViolation, with: :handle_not_null_violation

    private

    def handle_not_null_violation(exception)
      render json: { errors: [ { title: "Invalid Data", detail: exception.message, status: :unprocessable_entity } ] }, status: :unprocessable_entity
    end
  end
end
