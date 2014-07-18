Grassroots::Application.routes.draw do
  root to: 'pages#home' 
  get 'sign_in', to: 'sessions#new'
  post 'log_in', to: 'sessions#create'
  get 'log_out', to: 'sessions#destroy'

  mount Attachinary::Engine => "/attachinary"

  namespace :organization_admin do
    resources :projects, only: [:new, :create, :edit, :update]
    resources :organizations, only: [:edit, :update, :new, :create]
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
  
  resources :organizations, only: [:show, :index] do
    collection do
      get 'search', to: 'organizations#search', as: 'search'
    end
  end
  
  resources :projects, only: [:index, :show] do
    collection do
      get 'search', to: 'projects#search', as: 'search'
    end
  end
  get 'join', to: 'projects#join', as: 'join'

  resources :messages, only: [:new, :create, :index] 
  resources :volunteer_applications, only: [:new, :create]
  resources :contracts, only: [:create, :new, :destroy, :update]
  resources :work_submissions, only: [:new, :create]
  resources :conversations, only: [:show, :index]

  get 'forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get 'forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :password_resets, only: [:show, :create]
  get 'expired_token', to: 'password_resets#expired_token'

  resources :questions, only: [:index, :show, :new, :create, :edit, :update] do
    
    member do
      post '/votes', to: 'questions#vote'
    end

    resources :comments, only: [:create] do
      member do
        post '/votes', to: 'comments#vote'
      end
    end

    resources :answers, only: [:create] do
      member do
        post '/votes', to: 'answers#vote'
      end
      
      resources :comments, only: [:create] do
        member do
          post '/votes', to: 'comments#vote'
        end
      end
    end
  end

  resources :work_conversations, only: [:index]
  resources :categories, only: [:show]
  resources :badges, only: [:show]
  resources :relationships, only: [:create, :destroy]
  resources :newsfeed_items, only: [:index] do
    resources :comments, only: [:create]
  end
  resources :status_updates, only: [:create]

  resources :skills, only: [:create]
end
