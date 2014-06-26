class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      
      
      t.integer :item_id 
      t.integer :customer_id 
      t.integer :user_id  # who is assigned to solve this shite
      
      t.string :code
      
      t.datetime :complaint_date 
      t.text :complaint 
      t.integer :complaint_case # , :default => MAINTENANCE_CASE[:scheduled]  # or emergency
      
      
      t.text :diagnosis 
      t.integer :diagnosis_case # , :default => DIAGNOSIS_CASE[:all_ok]
      t.datetime :diagnosis_date
      t.boolean :is_diagnosed, :default => false  
      
      
      t.text :solution 
      t.integer :solution_case#  , :default => SOLUTION_CASE[:normal]
      t.datetime :solution_date 
      t.boolean :is_solved, :default => false 
      
      t.boolean :is_confirmed , :default => false
      
      t.boolean :is_deleted, :default => false 
      
      t.timestamps
    end
  end
end
