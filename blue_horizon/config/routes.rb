# frozen_string_literal: true

Rails.application.routes.draw do
  # Welcome
  root to: redirect('/welcome')
  get '/welcome', to: 'welcome#index'
  # switch paths
  get '/welcome/simple', to: 'welcome#simple', as: 'simple'
  get '/welcome/advanced', to: 'welcome#advanced', as: 'advanced'
  put '/welcome/reset-session', to: 'welcome#reset_session', as: 'reset_session'

  # Cluster size
  resource :cluster, only: [:show, :update]
  # Additional data
  resource :variables, only: [:show, :update]
  # Custom/Advanced
  resources :sources, except: [:show]

  resource :sources do
    get 'validate_terra', on: :member
  end
  # Show plan
  resource :plan, only: [:show, :update]
  # Deploy
  resource :deploy, only: [:update, :destroy]

  resource :deploy do
    get 'send_current_status', on: :member
  end
  get '/wrapup', to: 'wrapup#index'
  get '/download', to: 'download#download'
end
