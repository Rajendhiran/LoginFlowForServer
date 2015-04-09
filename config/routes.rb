Rails.application.routes.draw do

  use_doorkeeper
  devise_for :users, controllers: {
    passwords: "custom_devise/passwords"
  }

  get 'protected_page' => 'home#protected_page'
  get 'unprotected_page' => 'home#unprotected_page'
  get 'successful_password_reset' => 'home#successful_password_reset'
  root 'home#index'
end
