Rails.application.routes.draw do
  root 'sessions#index'
  resources :personal_characteristics, only: [:create, :destroy]
  resources :patients, only: [:index, :show]
  get 'home', to: 'sessions#index'
  post 'connect', to: 'sessions#create'
  get 'disconnect', to: 'sessions#destroy'
  get 'dashboard', to: 'dashboard#main'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
