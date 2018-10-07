Ebydict::Application.routes.draw do
  get "definition/list"
  get "definition/listpub"

  get "definition/review"

  get "definition/publish"

  get "definition/reproof"
  match 'definition/unassign/:id' => 'definition#unassign', via: [:get, :post]

  match 'definition/view/:id' => 'definition#view', via: [:get, :post]
  match 'definition/render_tei/:id' => 'definition#render_tei', via: [:get, :post]

  get "problem/list"

  get "problem/resolve"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  get 'login/login'
  get 'login/do_login'
  get 'login/logout'
  post 'login/do_login'
  get 'user/index'
  get 'user/list'
  get 'user/active_emails'
  get 'user/show'
  match 'user/show/:id' => 'user#show', via: [:get, :post]
  get 'admin/adduser'
  post 'admin/doadduser'
  get 'admin/changes'
  get 'scan/partition'
  match 'scan/dopartition/:id' => 'scan#dopartition', via: [:get, :post]
  match 'scan/docolpart/:id' => 'scan#docolpart', via: [:get, :post]
  match 'scan/dopartdef/:id' => 'scan#dopartdef', via: [:get, :post]
  match 'type/edit/:id' => 'type#edit', via: [:get, :post]
  match 'type/proof/:id' => 'type#proof', via: [:get, :post]
  match 'type/processtype/:id' => 'type#processtype', via: [:get, :post]
  match 'type/set_marker/:id' => 'type#set_marker', via: [:get, :post]
  get 'problem/list'
  match 'problem/tackle/:id' => 'problem#tackle', via: [:get, :post]
  get 'scan/part_col'
  get 'scan/part_def'
  get 'type/get_def'
  get 'type/edit'
  get 'type/get_fixup'
  get 'type/get_proof'
  get 'type/abandon'
  get 'publish/list'
  get 'scan/import'
  get 'scan/doimport'
  get 'scan/list'
  get 'scan/abandon'
  get 'scan/abandon_col'

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :eby_users

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
  root :to => 'user#index'
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
