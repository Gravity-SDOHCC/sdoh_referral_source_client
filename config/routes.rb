Rails.application.routes.draw do
  get 'dashboard', to: 'dashboard#main'
  root 'home#index'
  get 'home', to: 'home#index'
  post 'connect', to: 'home#connect'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
