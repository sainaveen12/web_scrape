class Item < ApplicationRecord
	belongs_to :restaurant
	belongs_to :category
end
