OrvaEvents::Application.routes.draw do
  devise_for :users
  resources :users
  resources :events do
    member do
      put :approve
      put :dismiss
    end
    collection do
      get 'filter/:status' => 'events#index', :as => 'filtered'
    end
  end

  root :to => 'events#index'
end
