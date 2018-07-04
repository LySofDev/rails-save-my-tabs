Rails.application.routes.draw do
  resources :users, only: [:create, :update]
end
