class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name
      t.decimal :price,default: 0
      t.text :description 
      t.integer :category_id
      t.integer :restaurant_id

      t.timestamps
    end
  end
end
