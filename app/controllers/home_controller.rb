class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:protected_page]
  helper_method :client_mobile?

  def index
  end

  def protected_page
  end

  def unprotected_page
  end

  def successful_password_reset
  end

  def successful_confirmation
  end


  private

  def client_mobile?
    request.user_agent.to_s.downcase =~ /android|iphone|ipad/
  end
end
