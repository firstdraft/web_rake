WebRake::Engine.routes.draw do
  root to: 'tasks#index'

  get '/:id', to: 'tasks#show', as: :task
  post '/:id/execute', to: 'tasks#execute', as: :execute_task
end