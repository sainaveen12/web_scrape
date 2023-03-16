class RestaurantController < ApplicationController
    def categories_type
        @categories = Category.all
    end
    def index
        @categories = Category.all
    end
end
