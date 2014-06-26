class CreateWarehouseItems < ActiveRecord::Migration
  def change
    create_table :warehouse_items do |t|

      t.timestamps
    end
  end
end
