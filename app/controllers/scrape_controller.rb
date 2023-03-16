
class ScrapeController < ApplicationController
    require 'open-uri'
    require 'nokogiri'
    def index
    end
    def get_data

        if params[:search_link].present?

            url = params[:search_link]
            page = Nokogiri::HTML(URI.open(url))

            restaurant_name = page.css('.v2').text.strip
            restaurant = Restaurant.where(name:restaurant_name).first
            unless restaurant.present?
                restaurant = Restaurant.create(name:restaurant_name)
            end

            page.css('.categoryListing').each do |article|
                title = article.css('.categoryHeading').text
                category = Category.where(name:title,restaurant_id:restaurant.id).first
                unless category.present?
                    category = Category.create(name: title,restaurant_id:restaurant.id) 
                end


                itemDetails = article.css(".itemDetails")
                itemDetails.each do |c|
                    unless Item.where(category_id:category.id,name:c.css('.itemName').text).present?
                        item = Item.new
                        item.name= c.css('.itemName').text
                        item.price= c.css('.itemPrice').text.remove(" â\u0082¹").to_d
                        item.description= c.css('.description').text
                        item.category_id = category.id
                        item.restaurant_id = restaurant.id
                        item.save
                    end
                end
            end
            # categories  = Category.where(name:category.name).first
        end
    end
end
