class CreateContractItems < ActiveRecord::Migration
  def change
    create_table :contract_items do |t|
      t.integer :contract_maintenance_id 
      t.integer :customer_id 
      
    
      
      t.integer :item_id
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
