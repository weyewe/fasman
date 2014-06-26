class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      
      t.string :name 
      t.text :address
      t.text :pic
      t.text :contact
      t.string :email 
      
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
