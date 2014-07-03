Ticketie::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'
  
  
  namespace :api do
    devise_for :users
    post 'authenticate_auth_token', :to => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token 
    put 'update_password' , :to => "passwords#update" , :as => :update_password
    get 'search_role' => 'roles#search', :as => :search_role, :method => :get
    get 'search_user' => 'app_users#search', :as => :search_user, :method => :get
    get 'search_item_type' => 'item_types#search', :as => :search_item_type, :method => :get
    get 'search_item' => 'items#search', :as => :search_item, :method => :get
    get 'search_customer' => 'customers#search', :as => :search_customer, :method => :get
    get 'search_warehouse' => 'warehouses#search', :as => :search_warehouse, :method => :get
    get 'search_contact' => 'contacts#search', :as => :search_contact, :method => :get
    get 'search_purchase_order' => 'purchase_orders#search', :as => :search_purchase_order, :method => :get
    
    # master data 
    resources :app_users
    resources :customers 
    resources :item_types  
    resources :items 
    
    resources :maintenances
    
    resources :contacts 
    resources :machines
    resources :components 
    resources :compatibilities
    
    resources :stock_adjustments
    resources :stock_adjustment_details
    
    resources :purchase_orders
    resources :purchase_order_details 
    
    resources :purchase_receivals
    resources :purchase_receival_details 
    
    
  end
  
  
end
