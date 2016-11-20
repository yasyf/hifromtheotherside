Rails.application.routes.draw do
  root to: 'responses#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :responses

  resources :admin do
    root to: 'admin#index'
  end
end
