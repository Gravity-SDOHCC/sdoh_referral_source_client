Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#main'
  root 'sessions#index'
  get 'home', to: 'sessions#index'
  post 'connect', to: 'sessions#create'
  get 'disconnect', to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
