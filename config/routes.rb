Hacktracker::Application.routes.draw do

  root :to => 'hackdays#index'

  resources :users, only: :show

  get 'tags/:tag', to: 'hacks#index', as: :tag
  # hacksroot to: 'hacks#index'

  resources :hackdays do
    member do
      get :queue, :display_queue
      get :judges
      post :start_presentations, :end_presentations
      put :break, to: 'hackdays#add_break', as: 'add_break'
      delete :break, to: 'hackdays#remove_break', as: 'remove_break'
      put    :admin, to: 'hackdays#add_admins',    as: 'add_admins'
      delete :admin, to: 'hackdays#delete_admin',  as: 'delete_admin'
    end
    resources :hacks, only: [:index, :create]
    resources :activities, only: [:index]
  end

  resources :hacks, only: [:show, :edit, :update, :destroy, :index] do
    get :autocomplete_tag_name, :on => :collection
    member do
      post :move_up_in_queue, :move_down_in_queue, :move_to_position,
           :finish_presentation, :join_queue, :leave_queue, :downvote, :upvote
      post :add_contribution
      post :add_contributions
      post :remove_contribution
      post :update_tags
    end
    resources :activities, only: [:index]
  end

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match '/auth/failure', to: redirect('/'), via: [:get, :post]
  get '/signout', to: 'sessions#destroy', as: 'signout'

  resources :comments
  # resources :activities

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
