class CreateRestaurants < ActiveRecord::Migration[7.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :location
      t.text :about
      t.string :address
      t.string :reference_id
      t.string :restaurant_type

      t.timestamps
    end
  end
end
