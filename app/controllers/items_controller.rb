class ItemsController < ApplicationController
	def show
		@item = Item.where(name:params[:name].titleize,restaurant_id:params[:restaurant_id]).first
	end
end
