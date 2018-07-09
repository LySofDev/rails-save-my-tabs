Rails.application.routes.draw do
  resources :users, only: [:create, :update, :destroy]
  post 'users/authenticate', to: 'users#authenticate', as: 'authenticate_user'
  get 'tabs', to: 'tabs#index', as: 'tabs'
  get 'tabs/:id', to: 'tabs#show', as: 'tab', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
  post 'tabs', to: 'tabs#create'
  patch 'tabs/:id', to: 'tabs#update', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
  delete 'tabs/:id', to: 'tabs#destroy', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
  get 'tabs/count', to: 'tabs#count', as: 'tab_count'
end
