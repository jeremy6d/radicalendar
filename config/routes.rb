OrvaEvents::Application.routes.draw do
  devise_for :users
  resources :users
  resources :events do
    put :approve
    put :dismiss
    get '/:status' => 'events#index', :as => 'filtered'
  end

  root :to => 'events#index'
end
