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
  # get '/scrape_data', to: 'scrape#my_new_api', as: :my_new_api
  # resources :scrape



end
