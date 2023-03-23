
class ScrapeController < ApplicationController
    require 'open-uri'
    require 'nokogiri'
    def index
    end
    def get_data

        if params[:search_link].present?

            @url = params[:search_link]
            if @url.include?"magicpin"
                magic_pin_data
            elsif @url.include?"zomato.com"
                zomato_data
            end
        end
    end
    def magic_pin_data
        page = Nokogiri::HTML(URI.open(@url))

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
            Item.where(category_id:category.id,restaurant_id:@restaurant.id).update_all(available:false)
            itemDetails.each do |c|
                item = Item.where(category_id:category.id,name:c.css('.itemName').text,restaurant_id:@restaurant.id).first
                unless item.present?
                    item = Item.new
                    item.name= c.css('.itemName').text
                    item.price= c.css('.itemPrice').text.remove(" â\u0082¹").to_d
                    item.description= c.css('.description').text
                    item.category_id = category.id
                    item.restaurant_id = @restaurant.id
                    item.save
                end
                item.available = true
                item.save
            end
        end
        @categories  = @restaurant.categories
    end
    def zomato_data
        headers={'Content-Type':'application/json','Accept':'*/*','Accept-Encoding':'gzip, deflate, br','Connection':'keep-alive','Cache-Control':'no-cache','User-Agent':'PostmanRuntime/7.31.3'}
        response = HTTParty.get(@url, headers: headers)
        page = Nokogiri::HTML(response)
        # puts page.inspect

        restaurant_name = page.xpath('//h1[@class="sc-7kepeu-0 sc-iSDuPN fwzNdh"]').text
        @restaurant = Restaurant.where(name:restaurant_name).first
        unless @restaurant.present?
            @restaurant = Restaurant.new
            @restaurant.name = restaurant_name
            @restaurant.location = page.css('.sc-clNaTc').text.strip
            # @restaurant.about = page.css('.merchant-description').first.children.first.text.strip
            @restaurant.restaurant_type = page.css('.sc-fgfRvd').text.strip
            reference_id = "#{@restaurant.name.parameterize}"
            loop do
                break reference_id unless Restaurant.exists?(reference_id: reference_id)
                reference_id = "#{@restaurant.name.parameterize}#{rand.to_s[2..3]}"
            end
            @restaurant.reference_id = reference_id
            @restaurant.save
        end

        # puts page.xpath('//section//section//section//section//section')..inspect
        # puts page.xpath('//section//section//section//section//section//section').text.inspect
        # puts page.css('.sc-jEdsij').text.inspect
        page.xpath('//section//section//section//section//section').each do |article|
            # title = page.css('section section section h4').text
            # item = article.xpath('//h4[@class="sc-1s0saks-15 iSmBPS""]').first.content
            # puts title.inspect
            # puts item.inspect
            # next
            # return
            category = Category.where(name:'Available').first
            unless category.present?
                category = Category.create(name: 'Available') 
            end
            # puts category.inspect
            categories_restaurant = CategoriesRestaurant.find_by(category_id: category.id, restaurant_id: @restaurant.id)
            unless categories_restaurant.present?
                categories_restaurant = CategoriesRestaurant.create(category_id: category.id, restaurant_id: @restaurant.id)
            end

            itemDetails = page.search('.sc-1s0saks-13.kQHKsO')
            Item.where(category_id:category.id,restaurant_id:@restaurant.id).update_all(available:false)
            itemDetails.each do |c|
                item = Item.where(category_id:category.id,name:c.xpath('h4[@class="sc-1s0saks-15 iSmBPS"]').text,restaurant_id:@restaurant.id).first
                unless item.present?
                    item = Item.new
                    item.name= c.xpath('h4[@class="sc-1s0saks-15 iSmBPS"]').text;
                    item.price= c.xpath('div[@class="sc-17hyc2s-3 jOoliK sc-1s0saks-8 gYkxGN"]').text.remove("₹").to_d
                    item.description= c.css('.sc-1s0saks-12.hcROsL').text;
                    item.category_id = category.id
                    item.restaurant_id = @restaurant.id
                    item.save
                end
                item.available = true
                item.save
            end
        end
        @categories  = @restaurant.categories
    end
end
