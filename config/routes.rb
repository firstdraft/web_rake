WebRake::Engine.routes.draw do
  root to: 'tasks#index'

  resources :tasks, only: [:index, :show] do
    member do
      post :execute
    end
  end
end