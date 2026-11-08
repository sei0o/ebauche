Rails.application.routes.draw do
  root "refs#index"

  resources :refs, except: :edit do
    get :next_unannotated, on: :collection
    resources :studies, only: :create
  end

  resources :studies, only: %i[index show update destroy]

  namespace :api do
    resources :refs, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
