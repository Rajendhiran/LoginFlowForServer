class Api::V1::UsersController < Api::ApiController
  def forget_password
    user = get_api_entity User.find_by_email(params[:email])

    user.send_reset_password_instructions
    render_success
  end

  def create
    raise_auth_missing_errors_if_empty_params :email, :password
    user = User.find_by_email(params[:email].to_s.downcase)
    if user
      render_errors(4010, "Email already exists")
    else
      # create new user here, and add more info here
      user = User.new(email: params[:email].to_s.downcase, password: params[:password])

      if user.save
        render_success
      else
        render_errors(4022, "Attributes are invalid", 401, full_messages: user.errors.full_messages)
      end
    end
  end
end
