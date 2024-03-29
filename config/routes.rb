Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: { registrations: "registrations", omniauth_callbacks: 'omniauth_callbacks' } do
    get "logout", to: "devise/sessions#destroy"
  end

  namespace :admin do
    root to: 'base#home'
    resources :emails do
      member do
        get :send_to_list
        get :send_test
        post :send_test_address
      end
    end
    resources :expenses
    resources :posts
    resources :pages
    resources :meetings
    resources :questions
    resources :seasons
    resources :stakes
  end

  resources :activities do
    collection do
      get :chronological
    end
  end

  resources :bankstatements

  resources :charges

  resources :comments do
    resources :comments
  end

  resources :emailannouncements

  resources :events do
    collection do
      get :calendar
      get :fullcalendar
      get :archive
    end
    resources :comments
    resources :instances, path: '' do
      resources :registrations, controller: :event_registrations
      resources :userphotos, controller: :viewpoints
      resources :userthoughts, controller: :viewpoints
      member do
        post :rsvp
        post :register
        get :add_registration_form
        post :cancel_rsvp
        post :cancel_registration
        get :stats
        resources :users do
          get :make_organiser
          get :remove_organiser
        end
      end
    end
  end

  resources :instances, only: :update

  resources :groups do
    collection do
      get :check_vat
      post :group_members_agreement
      post :group_nonmember_agreement
      post :member_details
      post :new_unregistered
      post :new_nonmember
    end
    member do
      get :buy_stakes
      get :edit_details
      get :join_cooperative
      get :basic_details
    end
    resources :members do
      member do
        get :leave
        get :toggle_key
        post :remove
      end
    end
    resources :transfers do
      collection do
        get :send_points
        post :post_points
      end
    end
  end

  resources :ideas do
    resources :comments
    collection do
      get :calendar
      get :archive
    end
    member do
      get :publish_event
      get :original_proposal
      get :cancel
    end
    resources :pledges do
      collection do
        get :find_pledge
      end
    end
    resources :build, controller: 'ideas/build'
    resources :thing, controller: 'ideas/thing'
    resources :request, controller: 'ideas/request'
  end

  resources :meetings do
    resources :comments
    member do
      post :rsvp
      post :cancel_rsvp
    end
    resources :users do
      resources :notifications
    end
  end

  resources :members do
    get :autocomplete_user_username, on: :collection
  end

  resources :onetimers do
    collection do
      post :link_tag
    end
  end

  resources :pages do
    resources :questions do
      resources :answers do
        resources :comments
      end
    end
  end

  resources :posts do
    collection do
      get :stakeholders
    end
    resources :comments
    resources :users do
      resources :notifications
    end
  end

  resources :nfcs, only: %i[index destroy]

  resources :roombookings do
    collection do
      get :calendar
    end
  end

  resources :questions do
    member do
      get :contribute_translation
    end
  end

  resources :budgetproposals do
    resources :comments
    member do
      get :find_vote
    end
  end

  resources :seasons do
    resources :groups do
      resources :stakes
    end

    resources :budgetproposals do
      resources :budgetproposal_votes
      member do
        post :vote
        get :discuss
        resources :comments
      end
    end

    resources :stakes do
      collection do
        get :for_self
        get :for_group
      end
    end
  end

  resources :hardware

  resources :users do
    get :stakeholder_refund
    collection do
      get :check_unique
      get :mentions

      get :members_agreement
    end
    member do
      get :consent
      get :buy_photoslot
    end
    resources :nfcs
    resources :transfers do
      collection do
        get :send_points
        post :post_points
      end
    end
    resources :stakes
    resources :groups
    resources :ideas
    member do
      get :set_pin
      get :get_avatar
      get :get_membership_details
    end
  end

  post '/clear_idcard_info', to: 'application#clear_idcard_info'
  get '/instances/:id', to: redirect("/events/%{id}")
  match '/redeem' => 'onetimers#link', via: :get
  match '/calendar' => 'events#calendar', via: :get
  match '/users/auth/:provider/callback' => 'authentications#create', :via => :get
  match '/home/front_calendar/' => 'home#front_calendar', via: :get
  match '/home/funders_update' => 'home#funders_update', via: :get
  delete '/users/signout' => 'devise/sessions#destroy', :as => :signout
  match '/nfcs/:id/toggle' => 'nfcs#toggle_key', via: :get
  match '/stakeholders' => 'home#stakeholders', via: :get
  match '/raha' => 'home#raha', via: :get
  match '/announcements/next_week' => 'emails#next_week', via: :get
  match '/announcements/this_week' => 'emails#this_week', via: :get
  match '/announcements/:id' => 'emails#show', via: :get
  root to: 'home#index'
end
