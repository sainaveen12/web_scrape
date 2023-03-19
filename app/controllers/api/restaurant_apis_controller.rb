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
        	items = restaurant.items.where("LOWER(name) LIKE ?","%#{name.downcase}%")
            categories = Category.where("id in (?)",items.pluck(:category_id).uniq)
        else
            categories = restaurant.categories
            items = restaurant.items
        end
        data =[]

        categories.each do |category|
        	data<<{
        	category_name: category.name,
        	items:Item.where("id in (?) and restaurant_id=? and category_id=?",items.pluck(:id),restaurant.id,category.id)
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
        return render json: {message: "invalid params"}, status: 422 if !params.present? 
        puts params[:orders].inspect   
        total_price = params[:orders].pluck(:price).sum
    	order = Order.create!(total_price:total_price, order_code: SecureRandom.hex())
        if order
            params[:orders].each do |order_item|
                OrderItem.create!(order_id: order.id, quantity: order_item['quantity'], price: order_item['price'], item_id: order_item['item_id'])
            end
            render json: {message: "order created succesfully", order_data: OrderSerializer.new(order).to_hash}
        else
            render json: {message: "order not created"}, status: 422 
        end
    end

    private
    def order_params
        params.permit(orders: %i[item_id quantity price])
    end
end
