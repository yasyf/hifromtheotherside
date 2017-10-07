Rails.application.routes.draw do
  root to: 'responses#index'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  resources :responses do
    collection do
      get 'questions'
    end
  end

  resources :admin, only: [:index, :destroy] do
    member do
      post 'pair'
    end
  end

  post 'hook', controller: 'webhook'
end
