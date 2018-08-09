Rails.application.routes.draw do
################################################################################
# Health Check
################################################################################
  get 'status', to: 'health#status'
  get 'reset', to: 'health#reset'
################################################################################
# User Registration
################################################################################
  post 'users', to: 'users#create'
  patch 'users', to: 'users#update'
  delete 'users', to: 'users#destroy'
################################################################################
# User Authentication
################################################################################
  post 'users/authenticate', to: 'users#authenticate', as: 'authenticate_user'
################################################################################
# Tab Resource
################################################################################
  post 'tabs', to: 'tabs#create'
  get 'tabs', to: 'tabs#index'
  get 'tabs/:id', to: 'tabs#show', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
  patch 'tabs/:id', to: 'tabs#update', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
  delete 'tabs/:id', to: 'tabs#destroy', constraints: { id: /[0-9]+(\%7C[0-9]+)*/ }
end
