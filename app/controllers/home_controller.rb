class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:protected_page]

  def index
  end

  def protected_page
  end

  def unprotected_page
  end

  def successful_password_reset
  end

  def successful_confirmation
    # check if it's a mobile or not
  end
end
