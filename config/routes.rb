Rails.application.routes.draw do

  use_doorkeeper
  devise_for :users, controllers: {
    passwords: "custom_devise/passwords"
  }

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :user, only: [:create, :update] do
        post :forget_password, on: :collection
      end
    end
  end

  get 'protected_page' => 'home#protected_page'
  get 'unprotected_page' => 'home#unprotected_page'
  get 'successful_password_reset' => 'home#successful_password_reset'
  root 'home#index'
end
