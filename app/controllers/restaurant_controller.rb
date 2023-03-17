class RestaurantController < ApplicationController
    def categories_type
        @categories = Category.all
    end
    def index
        location = params[:location]
        if location.present?
            @restaurants = Restaurant.where("LOWER(location) like ?","%#{location.downcase}%")
            puts @restaurants.inspect
        else
            @restaurants = Restaurant.first(5)
        end
    end
    def show
        @restaurant = Restaurant.where("lower(name) LIKE ?","%#{params[:id].titleize.downcase}%").first
        @name = params[:search_name]
        if @name.present?
            @categories = @restaurant.categories.where("LOWER(name) LIKE ?","%#{@name.downcase}%")
        else
            @categories = @restaurant.categories
        end
    end
end
