Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :mod, only: [:create]
  root to: 'home#index'
end
