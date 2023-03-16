Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  # root "restaurant#index"
  root 'restaurant#index'
  # get 'scrape/get_data'
  # match '/scrape_data' => 'scrape#index', :method => :get
  match '/get_data', to: 'scrape#get_data', via: [:post]
  match '/scrape', to: 'scrape#index', via: [:get]
  match '/restaurant/:id', controller: 'restaurant',action:'show', via: [:get],:as => 'restaurant'
  match '/restaurant/:name/:restaurant_id', controller: 'items',action:'show', via: [:get],:as => 'item'
  
  # get '/scrape_data', to: 'scrape#my_new_api', as: :my_new_api
  # resources :restaurant



end
