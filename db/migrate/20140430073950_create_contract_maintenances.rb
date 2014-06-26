class CreateContractMaintenances < ActiveRecord::Migration
  def change
    create_table :contract_maintenances do |t|

      t.integer :customer_id 
      t.string :name 
      t.text :description 
      t.string :code 
      t.datetime :started_at
      t.datetime :finished_at 
      
      t.boolean :is_deleted, :default => false 
      
      t.timestamps
    end
  end
end
