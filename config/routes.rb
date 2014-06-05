Grassroots::Application.routes.draw do
  root to: 'pages#home' 
  get 'sign_in', to: 'sessions#new'
  post 'log_in', to: 'sessions#create'
  get 'log_out', to: 'sessions#destroy'

  namespace :organization_admin do
    resources :projects, only: [:new, :create, :edit, :update]
    resources :organizations, only: [:edit, :update]
    resources :volunteer_applications, only: [:index]
  end

  namespace :volunteer do
    resources :volunteer_applications, only: [:index]
  end

  resources :users, except: [:destroy] do
    collection do
      get 'search', to: 'users#search', as: 'search'
    end
  end
  delete 'remove', to: 'users#remove'
  resources :organizations, only: [:show, :index, :new, :create]
  resources :projects, only: [:index, :show] do
    collection do
      get 'search', to: 'projects#search', as: 'search'
    end
  end
  get 'join', to: 'projects#join', as: 'join'

  resources :private_messages, only: [:new, :create] 
  #get 'outgoing_messages', to: 'private_messages#outgoing_messages', as: 'outgoing_messages'
  resources :volunteer_applications, only: [:new, :create]
  
  resources :contracts, only: [:create, :new, :destroy, :update]
  #patch 'dropping_contract', to: 'contracts#dropping_contract', as: 'dropping_contract'
  #patch 'update_contract_work_submitted/:id', to: 'contracts#update_contract_work_submitted', as: 'update_contract_work_submitted'
  #patch 'contract_complete', to: 'contracts#contract_complete', as: 'contract_complete'
  #get 'submit_work_form', to: 'contracts#submit_work_message_form', as: 'submit_work_form'

  resources :work_submissions, only: [:new, :create]

  resources :conversations, only: [:show, :index]
end
