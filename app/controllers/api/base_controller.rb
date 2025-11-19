module Api
  class BaseController < ActionController::Base
    protect_from_forgery with: :null_session

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordNotSaved, with: :record_not_saved
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

    private

    def render_not_found(exception)
      model_name = exception.model rescue nil
      render json: { errors: [ jsonapi_error(exception.message, "Not Found", :not_found, model_name) ] }, status: :not_found
    end

    def record_not_saved(exception)
      render json: { errors: [ jsonapi_error(exception.message, "Unprocessable Entity", :unprocessable_entity) ] }, status: :unprocessable_entity
    end

    def render_unprocessable_entity(exception)
      record = exception.record
      errors = record.errors.map do |error|
        jsonapi_error(error.full_message, "Unprocessable Entity", :unprocessable_entity, "/data/attributes/#{error.attribute}")
      end
      render json: { errors: errors }, status: :unprocessable_entity
    end

    def jsonapi_error(detail, title, status, source_pointer = nil)
      error ={ "title" => title.to_s, "detail" => detail.to_s, "status" => normalize_status(status) }
      error["source"] = { "pointer" => source_pointer } unless source_pointer.blank?
      error
    end

    def normalize_status(status)
      return status.to_s if status.is_a?(String) && status =~ /^\d+$/
      Rack::Utils.status_code(status).to_s
    end
  end
end
