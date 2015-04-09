class RecordNotFoundError < StandardError; end

class Api::ApiController < ActionController::Base

  rescue_from RecordNotFoundError do
    render_errors 4004, "Record not found", 401
  end

  def render_errors status_code, error_message, http_code = 400, error_data = {}, extra_data = {}
    error = { message: error_message }
    if params[:dev].present?
      params.each{ |k, v| params[k] = "(binary)" unless v.is_a? String }
      error[:params] = params.to_hash.merge({path: request.url})
    end
    error.merge!(error_data) if error_data.present?
    render json: {status_code: status_code, error: error}.merge(extra_data), status: http_code
  end

  def render_success message = "success", extra_data = {}
    render json: {status_code: 0, status: message}.merge(extra_data)
  end

  def get_api_entity entity, klass = nil
    message = klass.nil? ? "" : "#{klass.to_s} record is not found!"
    raise RecordNotFoundError, message if entity.nil?
    entity
  end
end
