Rails.application.routes.draw do
  root to: 'animals#index'
  resources :animals, only: [:index, :show, :new, :create]
end
