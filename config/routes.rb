OrvaEvents::Application.routes.draw do
  devise_for :users
  resources :users
  resources :events

  root :to => 'events#index'
end
