Rails.application.routes.draw do

  use_doorkeeper
  devise_for :users

  get 'protected_page' => 'home#protected_page'
  get 'unprotected_page' => 'home#unprotected_page'
  root 'home#index'
end
