class OrderSerializer < ActiveModel::Serializer
	attributes :total_price, :order_code
end