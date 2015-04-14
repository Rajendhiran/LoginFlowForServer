module Doorkeeper
  module Helpers::Controller
    alias_method :old, :get_error_response_from_exception

    def get_error_response_from_exception(exception)
      error_name = nil
      case exception
      when Errors::Facebook::InvalidToken
        error_name = :facebook_invalid_token
        message = "Invalid Facebook token"
      end


      if error_name
        # OAuth::ErrorResponse.new name: error_name, state: params[:state]
        CustomError.new name: error_name, state: params[:state], meta_data: {
          status_code: 4001,
          error: {
            message: "#{error_name}: #{message}"
          }
        }
      else
        old exception
      end
    end
  end


  class CustomError < OAuth::ErrorResponse

    def initialize(attributes = {})
      @meta_data = attributes[:meta_data]
      super(attributes)
    end

    def body
      if @meta_data.present?
        @meta_data
      else
        super
      end
    end
  end

  module Errors
    module Facebook
      class InvalidToken < DoorkeeperError
      end
    end
  end
end
