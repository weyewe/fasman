class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      
      t.integer :customer_id 
      t.integer :item_type_id 
      
      t.string :code 
      t.text :description
      
      t.datetime :manufactured_at 
      t.datetime :warranty_expiry_date 
      
      t.boolean :is_deleted , :default => false 

      t.timestamps
    end
  end
end
