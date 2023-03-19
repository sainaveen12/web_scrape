class Api::RestaurantApisController < ApplicationController
	def get_data_api

        if params[:search_link].present?

            url = params[:search_link]
            page = Nokogiri::HTML(URI.open(url))

            restaurant_name = page.xpath('//h1[@class="v2"]').text.strip
            restaurant = Restaurant.where(name:restaurant_name).first
            unless restaurant.present?
                restaurant = Restaurant.new
                restaurant.name = restaurant_name
                restaurant.location = page.css('.merchant-address-details').text.strip
                restaurant.about = page.css('.merchant-description').first.children.first.text.strip
                restaurant.restaurant_type = page.css('.merchant-establishment').first.children.first.text.strip
                reference_id = "#{restaurant.name.parameterize}"
                loop do
                    break reference_id unless Restaurant.exists?(reference_id: reference_id)
                    reference_id = "#{restaurant.name.parameterize}#{rand.to_s[2..3]}"
                end
                restaurant.reference_id = reference_id
                restaurant.save
            end
            page.css('.categoryListing').each do |article|
                title = article.css('.categoryHeading').text
                category = Category.where(name:title).first
                unless category.present?
                    category = Category.create(name: title) 
                end
                 categories_restaurant = CategoriesRestaurant.find_by(category_id: category.id, restaurant_id: restaurant.id)
                unless categories_restaurant.present?
                    categories_restaurant = CategoriesRestaurant.create(category_id: category.id, restaurant_id: restaurant.id)
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
            scraped_data ={
            	restaurant: restaurant,
            	categories:restaurant.categories,
            	items:restaurant.items

            }
            render json: scraped_data
        end
    end
    def index_api
        search = params[:search]
        if search.present?
            restaurants = Restaurant.where("LOWER(location) LIKE ? or LOWER(restaurant_type) LIKE ?","%#{search.downcase}%","%#{search.downcase}%")
        else
            restaurants = Restaurant.first(5)
        end
        render json: restaurants
    end
    def category_products_api
        reference_id = params[:id]
        restaurant = Restaurant.where("reference_id=?",reference_id).first
        name = params[:search_name]
        if name.present?
            categories = restaurant.categories.where("LOWER(name) LIKE ?","%#{name.downcase}%")
        else
            categories = restaurant.categories
        end
        data =[]

        categories.each do |category|
        	data<<{
        	category_name: category.name,
        	items:Item.where(restaurant_id:restaurant.id,category_id:category.id)
        	}

        end
        render json: {restaurant_name:restaurant.name ,categories:data}

    end
    def product_detail_api
    	item = Item.find(params[:id]) rescue nil
    	if item.present?
    		item_details={
    			name:item.name,
    			price:item.price,
    			description:item.description,
    			restaurant_name:item.restaurant.name,
    			category:item.category.name
    		}
    	end
        render json: item_details

    end
    def create_order
    	order = Order.create
    end
end
