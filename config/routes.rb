Rails.application.routes.draw do

  root :to => redirect('/projects')

  resources :messages
  resources :projects
  resources :companies

  devise_for :admins
  devise_for :users, controllers: { registrations: "registrations" }
  resources :users

  resources :projects do
    resources :input_files
    resources :quotations
    resources :invoices
    resources :output_files
  end
  
  get 'pages/info'
  get 'companies/:id/invitations/new' => 'invitations#new'
  post 'companies/:id/invitations' => 'invitations#create', :as => :invitations
  post 'projects/:id/accept' => 'projects#accept'
  post 'projects/:id/reject' => 'projects#reject'
  post 'companies/:id/leave' => 'companies#leave'
  get 'projects/:id/manage', to: 'projects#manage', :as => :manage_project
  post 'users/:id/grantManager' => 'users#grantManager'
  post 'users/:id/removeManagerPriv' => 'users#removeManagerPriv'
  match 'users/:id' => 'users#destroy', :via => :delete, :as => :admin_destroy_user
  get '/storage/inputFiles/:id/:basename.:extension' => 'input_files#download'
  get '/storage/quotations/:id/:basename.:extension' => 'quotations#download'
  get '/storage/invoices/:id/:basename.:extension' => 'invoices#download'
  get '/storage/outputFiles/:id/:basename.:extension' => 'output_files#download'

  match 'projects/:project_id/input_files/:id' => 'input_files#destroy', :via => :delete, :as => :destroy_input_file
  match 'projects/:project_id/quotations/:id' => 'quotations#destroy', :via => :delete, :as => :destroy_quotation
  match 'projects/:project_id/invoices/:id' => 'invoices#destroy', :via => :delete, :as => :destroy_invoice
  match 'projects/:project_id/output_files/:id' => 'output_files#destroy', :via => :delete, :as => :destroy_output_file

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"  

  #http://localhost:3000/uploads/project/job/108/scaffold.txt


  #match 'users/' => 'users#index', via: :get

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
