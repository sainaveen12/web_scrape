
class ScrapeController < ApplicationController
    require 'open-uri'
    require 'nokogiri'
    def index
    end
    def get_data

        if params[:search_link].present?

            url = params[:search_link]
            page = Nokogiri::HTML(URI.open(url))

            restaurant_name = page.xpath('//h1[@class="v2"]').text.strip
            @restaurant = Restaurant.where(name:restaurant_name).first
            unless @restaurant.present?
                @restaurant = Restaurant.new
                @restaurant.name = restaurant_name
                @restaurant.location = page.css('.merchant-address-details').text.strip
                @restaurant.about = page.css('.merchant-description').first.children.first.text.strip
                @restaurant.restaurant_type = page.css('.merchant-establishment').first.children.first.text.strip
                reference_id = "#{@restaurant.name.parameterize}"
                loop do
                    break reference_id unless Restaurant.exists?(reference_id: reference_id)
                    reference_id = "#{@restaurant.name.parameterize}#{rand.to_s[2..3]}"
                end
                @restaurant.reference_id = reference_id
                @restaurant.save
            end
            page.css('.categoryListing').each do |article|
                title = article.css('.categoryHeading').text
                category = Category.where(name:title).first
                unless category.present?
                    category = Category.create(name: title) 
                end
                categories_restaurant = CategoriesRestaurant.find_by(category_id: category.id, restaurant_id: @restaurant.id)
                unless categories_restaurant.present?
                    categories_restaurant = CategoriesRestaurant.create(category_id: category.id, restaurant_id: @restaurant.id)
                end

                itemDetails = article.css(".itemDetails")
                itemDetails.each do |c|
                    unless Item.where(category_id:category.id,name:c.css('.itemName').text).present?
                        item = Item.new
                        item.name= c.css('.itemName').text
                        item.price= c.css('.itemPrice').text.remove(" â\u0082¹").to_d
                        item.description= c.css('.description').text
                        item.category_id = category.id
                        item.restaurant_id = @restaurant.id
                        item.save
                    end
                end
            end
            @categories  = @restaurant.categories
        end
    end
end
