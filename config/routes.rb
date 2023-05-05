Rails.application.routes.draw do
  root "sessions#index"
  resources :personal_characteristics, only: [:new, :create, :destroy]
  resources :goals, only: [:create, :destroy]
  resources :patients, only: [:index, :show]
  resources :organizations, only: [:create]
  get "home", to: "sessions#index"
  post "connect", to: "sessions#create"
  get "disconnect", to: "sessions#destroy"
  get "select_test_practitioner", to: "sessions#select_test_practitioner"
  post "set_current_practitioner", to: "sessions#set_current_practitioner"
  get "dashboard", to: "dashboard#main"
  post "conditions", to: "conditions#create"
  get "conditions/:id/:status", to: "conditions#update_condition"
  get "goals/:id/:field", to: "goals#update_goal"
  post "tasks", to: "tasks#create"
  get "tasks/:id/:status", to: "tasks#update_task"
  get "poll_tasks", to: "tasks#poll_tasks"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
