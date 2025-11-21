module Api
  class BaseController < ActionController::Base
    include Pagy::Method
    protect_from_forgery with: :null_session

    before_action :permit_options, only: [ :index ]

    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordNotSaved, with: :record_not_saved
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

    # Pagy pagination helpers
    def paginate(results, options = {})
      pagy, records = if results.is_a? Array
        pagy_array(results, **options)
      else
        pagy(results, **options)
      end

      [ records, pagy ]
    end

    def normalize_pagination_params(params)
      options = (params || {}).to_h.symbolize_keys

      # the to_i calls will convert nil and non-numeric strings to 0
      page  = options[:page].to_i
      limit = options[:limit].to_i

      # handle invalid values by removing the key to use defaults
      page > 0 ? options[:page] = page : options.delete(:page)
      limit > 0 ? options[:limit] = limit : options.delete(:limit)
      options
    end


    def render_paginated(records, option_params = {})
      options = normalize_pagination_params(option_params)
      paginated_records, pagy = paginate(records, options)

      render json: {
        data: paginated_records,
        meta: {
          last: pagy.last,
          page: pagy.page,
          count: pagy.count,
          next: pagy.next,
          from: pagy.from,
          to: pagy.to
        }
      }, status: :ok
    end


    private

    # Before actions
    def permit_options
      params.permit(options: [ :page, :limit ])
    end

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
