Rails.application.routes.draw do
  root to: 'responses#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :responses

  resources :admin, only: [:index] do
    member do
      post 'pair'
    end
  end
end
