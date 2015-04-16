module Doorkeeper
  module Helpers::Controller
    alias_method :old, :get_error_response_from_exception
    
    def get_error_response_from_exception(exception)
      error_name = nil
      case exception
      when Errors::Facebook::InvalidToken
        error_name = :facebook_invalid_token
        message = "Invalid Facebook token"
        status_code = Utilities::ApplicationCode::INVALID_TOKEN_THIRD_PARTY
      when Errors::UsernamePassword::UserDoesNotExist
        error_name = :username_password_user_does_not_exist
        message = "User does not exist"
        status_code = Utilities::ApplicationCode::RECORD_NOT_FOUND_BY_EMAIL
      when Errors::UsernamePassword::InvalidPassword
        error_name = :username_password_invalid_password
        message = "Invalid password"
        status_code = Utilities::ApplicationCode::INVALID_PASSWORD
      when Errors::UsernamePassword::UserNotVerified
        error_name = :username_password_user_not_verified
        message = "User is not verified"
        status_code = Utilities::ApplicationCode::UNAUTHORIZED_UNVERIFIED
      end

      if error_name
        # OAuth::ErrorResponse.new name: error_name, state: params[:state]
        CustomError.new name: error_name, state: params[:state], meta_data: {
          status_code: status_code,
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
      class InvalidToken < DoorkeeperError; end
    end
    module UsernamePassword
      class UserDoesNotExist < DoorkeeperError; end
      class InvalidPassword < DoorkeeperError; end
      class UserNotVerified < DoorkeeperError; end
    end
  end
end
