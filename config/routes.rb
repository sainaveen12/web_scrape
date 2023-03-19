Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'restaurant#index'
  match '/get_data', to: 'scrape#get_data', via: [:post]
  match '/scrape', to: 'scrape#index', via: [:get]
  match '/restaurant/:id', controller: 'restaurant',action:'show', via: [:get],:as => 'restaurant'
  match '/restaurant/:reference_id/:id', controller: 'items',action:'show', via: [:get],:as => 'item'
  # apis routes
  match '/get_data_api', controller: 'api/restaurant_apis',action:'get_data_api', via: [:post],:as => 'get_data_api'
  match '/index_api', controller: 'api/restaurant_apis',action:'index_api', via: [:get],:as => 'index_api'
  match '/category_products_api', controller: 'api/restaurant_apis',action:'category_products_api', via: [:get],:as => 'category_products_api'
  match '/product_detail_api', controller: 'api/restaurant_apis',action:'product_detail_api', via: [:get],:as => 'product_detail_api'
  match '/create_order', controller: 'api/restaurant_apis',action:'create_order', via: [:post],:as => 'create_order'


  
  # resources :restaurant



end
