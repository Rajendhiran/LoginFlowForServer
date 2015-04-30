Rails.application.routes.draw do
  use_doorkeeper scope: 'api/v1/oauth' do
    skip_controllers :applications, :authorized_applications, :authorizations
    # or you can use below `controllers` instead
    # controllers :oauth
  end

  devise_for :users, controllers: {
    # customized controllers so that we can override to redirecting parts
    passwords: "custom_devise/passwords", # for redirecting to path after successfully reset passowrd
    confirmations: "custom_devise/confirmations" # for redirecting to path after successfully confirm email
  }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resource :user, only: [:create, :update] do
        post :forget_password
        put :sync_facebook
      end
    end
  end

  get 'protected_page' => 'home#protected_page'
  get 'unprotected_page' => 'home#unprotected_page'
  get 'successful_password_reset' => 'home#successful_password_reset'
  get 'successful_confirmation' => 'home#successful_confirmation'
  root 'home#index'
end
