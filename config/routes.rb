OrvaEvents::Application.routes.draw do
  devise_for :users
  resources :users
  resources :events do
    put :approve
    put :dismiss
  end

  root :to => 'events#index'
end
