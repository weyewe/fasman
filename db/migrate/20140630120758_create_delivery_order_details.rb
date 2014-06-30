class CreateDeliveryOrderDetails < ActiveRecord::Migration
  def change
    create_table :delivery_order_details do |t|
      t.integer :delivery_order_id 
      t.integer :delivery_order_detail_id  
      
      t.integer :quantity, :default => 0 
      
      
      t.boolean :is_confirmed, :default => false
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
