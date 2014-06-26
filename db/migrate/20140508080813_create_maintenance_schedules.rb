class CreateMaintenanceSchedules < ActiveRecord::Migration
  def change
    create_table :maintenance_schedules do |t|
      t.integer :contract_maintenance_id 
      t.datetime :maintenance_date 
      t.integer :customer_id
      
      t.boolean :is_deleted 
      
      t.timestamps
    end
  end
end
