class Api::V1::UsersController < Api::ApiController
  before_action :doorkeeper_authorize!, only: [:update, :sync_facebook]

  def forget_password
    user = get_api_entity User.find_by_email(params[:email])

    user.send_reset_password_instructions
    render_success
  end

  def sync_facebook
    fb = Facebook.new(params[:facebook_token])
    return render_errors Utilities::ApplicationCode::INVALID_TOKEN_THIRD_PARTY, "Invalid Facebook Token" unless (fb.profile rescue nil)

    user = User.find_by_fid(fb.id)
    if user
      render_errors Utilities::ApplicationCode::BAD_REQUEST_DUPLICATE_RECORD_FB, "Facebook account has been linked before"
    else
      current_resource_owner.update(fid: fb.id)
      render_success
    end
  end

  def create
    raise_auth_missing_errors_if_empty_params :email, :password
    user = User.find_by_email(params[:email].to_s.downcase)
    if user
      render_errors Utilities::ApplicationCode::BAD_REQUEST_DUPLICATE_RECORD, "Email already exists"
    else
      # create new user here, and add more info here
      user = User.new(email: params[:email].to_s.downcase.strip, password: params[:password])

      if user.save
        render_success
      else
        render_errors Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: user.errors.full_messages
      end
    end
  end


  def update
    user = current_resource_owner
    email = params[:email].to_s.downcase.strip

    if email.present?
      # update email

      if user.email == email
        render_errors(Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: ["Trying to update the same email"])
      else
        if user.update(email: email)
          render_success
        else
          render_errors(Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: user.errors.full_messages)
        end
      end

    elsif params[:password]
      if user.valid_password?(params[:old_password])
        if user.update(password: params[:password])
          render_success
        else
          render_errors(Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: user.errors.full_messages)
        end
      else
        render_errors(Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: ["Invalid old password"])
      end
    else
      render_errors(Utilities::ApplicationCode::UNPROCESSABLE_ENTITY, "Attributes are invalid", 400, full_messages: ["Nothing is updated"])
    end
  end
end
