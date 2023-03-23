class AddAvailableToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items,:available,:boolean,default: :false
    add_column :items,:item_type,:string
  end
end
