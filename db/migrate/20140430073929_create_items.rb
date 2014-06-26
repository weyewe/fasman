class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
     
      t.string :sku 
      t.text :description
      t.integer :quantity_ready , :default =>  0 
      
      t.boolean :is_deleted , :default => false 

      t.timestamps
    end
  end
end
