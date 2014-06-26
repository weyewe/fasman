class CreateTypes < ActiveRecord::Migration
  def change
    create_table :types do |t|
      
      t.string :name 
      t.text :description 
      t.boolean :is_deleted, :default  => false 

      t.timestamps
    end
  end
end
