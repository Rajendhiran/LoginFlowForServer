class Api::V1::UsersController < Api::ApiController
  def forget_password
    user = get_api_entity User.find_by_email(params[:email])

    user.send_reset_password_instructions
    render_success
  end
end
