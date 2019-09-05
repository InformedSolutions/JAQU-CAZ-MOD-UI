# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  authenticated(:user) { root 'upload#index', as: :authenticated_root }
  devise_scope(:user) { root to: 'devise/sessions#new' }

  resources :upload, only: %i[] do
    collection do
      post :import
      get :processing
      get :success
      get :data_rules
    end
  end

  resources :passwords, only: %i[new create] do
    collection do
      get '/', to: redirect('/')
      get :success
      get :reset
      post :send_confirmation_code
      get :confirm_reset
      post :change
    end
  end

  resources :cookies, only: :index

  get :health, to: 'application#health'
  get :build_id, to: 'application#build_id'

  match '/404', to: 'errors#not_found', via: :all
  # There is no 422 error page in design systems
  match '/422', to: 'errors#internal_server_error', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
