class CreateCategoriesRestaurants < ActiveRecord::Migration[7.0]
  def change
    create_table :categories_restaurants do |t|
      t.integer :category_id
      t.integer :restaurant_id

      t.timestamps
    end
  end
end
