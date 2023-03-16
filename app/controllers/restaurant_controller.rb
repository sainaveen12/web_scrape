class RestaurantController < ApplicationController
    def categories_type
        @categories = Category.all
    end
    def index
        location = params[:location]
        if location.present?
            @restaurants = Restaurant.where("location like (?)","%#{location.downcase}%")
        else
            @restaurants = Restaurant.first(5)
        end
         respond_to do |format|
          format.html 
          format.json { head :no_content }
          format.js   { render :layout => false }
       end
    end
    def show
        @restaurant = Restaurant.where(name:(params[:id].titleize)).first
        name = "Bowl"
        if name.present?
            @categories = @restaurant.categories.where("name LIKE ?","%#{name}%")
        else
            @categories = @restaurant.categories
        end
    end
end
