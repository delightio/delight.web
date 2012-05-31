require 'resque/server'

DelightWeb::Application.routes.draw do

  resources :invitations, :only => [:show, :new, :create] do
    put 'accept' => 'invitations#accept', :as => :accept
  end

  resources :users, :only => [:edit, :update] do
    get 'signup_info_edit' => 'users#signup_info_edit', :as => :signup_info_edit
    put 'signup_info_update' => 'users#signup_info_update', :as => :signup_info_update
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
    delete 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session
  end

  resources :accounts, :except => [:index, :destroy] do
    get 'credit', :to => 'accounts#view_credit', :as => 'view_credit'
    put 'add_credit', :to => 'accounts#add_credit', :as => 'add_credit'
  end

  resources :app_sessions, :only => [:show, :create, :update] do
    put '/favorite', :to => 'app_sessions#favorite', :as => 'favorite'
    put '/unfavorite', :to => 'app_sessions#unfavorite', :as => 'unfavorite'
  end
  resources :opengl_app_sessions, :only => [:create, :update]

  resources :tracks, :only => [:create, :show]
  resources :screen_tracks, :only => [:create]
  resources :touch_tracks, :only => [:create]
  resources :front_tracks, :only => [:create]
  resources :orientation_tracks, :only => [:create]

  # To be removed. This internally maps ScreenTrack
  resources :videos, :only => [:create, :show]

  resources :apps do
    put '/recording/update/:state', :to => 'apps#update_recording', :as => :update_recording
    get '/setup', :to => 'apps#setup', :as => :setup
    get '/schedule_recording_edit', :to => 'apps#schedule_recording_edit', :as => :schedule_recording_edit
    put '/schedule_recording_update', :to => 'apps#schedule_recording_update', :as => :schedule_recording_update
    put '/upload_on_wifi_only', :to => 'apps#upload_on_wifi_only', :as => :upload_on_wifi_only
  end
  resources :beta_signups, :only => [:create]

  match 'features' => 'home#features'
  match 'pricing' => 'home#pricing'
  match 'faq' => 'home#faq'
  match 'docs' => 'home#docs'
  match 'blog' => 'home#blog'
  root :to => 'home#index'

  resque_constraint = lambda do |request|
    if request.env['warden'].authenticate?
      if ENV['RESQUE_ADMIN_TWITTER_IDS']
        twitter_ids = ENV['RESQUE_ADMIN_TWITTER_IDS'].split(',').collect { |s| s.strip }
      else
        twitter_ids = []
      end

      if ENV['RESQUE_ADMIN_GITHUB_IDS']
        github_ids = ENV['RESQUE_ADMIN_GITHUB_IDS'].split(',').collect { |s| s.strip }
      else
        github_ids = []
      end

      twitter_ids.include? request.env['warden'].user.twitter_id \
      or github_ids.include? request.env['warden'].user.github_id
    else
      false
    end
  end
  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
