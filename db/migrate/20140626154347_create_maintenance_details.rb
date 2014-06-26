class CreateMaintenanceDetails < ActiveRecord::Migration
  def change
    create_table :maintenance_details do |t|
      
      t.integer :maintenance_id 
      t.integer :component_id 
      
      t.text :solution 
      t.integer :solution_case  
      
      t.integer :current_item_id 
      t.integer :replacement_item_id  # if it happens to be replacement with another item. 

      t.timestamps
    end
  end
end
