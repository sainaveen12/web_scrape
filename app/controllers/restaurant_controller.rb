class RestaurantController < ApplicationController
    def categories_type
        @categories = Category.all
    end
    def index
        @search = params[:search]
        if @search.present?
            @restaurants = Restaurant.where("LOWER(location) LIKE ? or LOWER(restaurant_type) LIKE ?","%#{@search.downcase}%","%#{@search.downcase}%")
        else
            @restaurants = Restaurant.first(5)
        end
    end
    def show
        reference_id = params[:id]
        @restaurant = Restaurant.where("reference_id=?",reference_id).first
        @name = params[:item_search]
        if @name.present?
            # @categories = @restaurant.categories.where("LOWER(name) LIKE ?","%#{@name.downcase}%")
            @items = @restaurant.items.where("LOWER(name) LIKE ?","%#{@name.downcase}%")
            @categories = Category.where("id in (?)",@items.pluck(:category_id).uniq)
        else
            @categories = @restaurant.categories
            @items = @restaurant.items
        end
    end
end
