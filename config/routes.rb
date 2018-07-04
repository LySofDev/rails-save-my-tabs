Rails.application.routes.draw do
  resources :users, only: [:create, :update, :destroy]
  post 'users/authenticate', to: 'users#authenticate', as: 'authenticate_user'
  resources :tabs, only: [:create, :update, :destroy]
end
