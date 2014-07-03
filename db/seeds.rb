role = {
  :system => {
    :administrator => true
  }
}

admin_role = Role.create!(
  :name        => ROLE_NAME[:admin],
  :title       => 'Administrator',
  :description => 'Role for administrator',
  :the_role    => role.to_json
)

role = {
  :passwords => {
    :update => true 
  },
  :works => {
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :work_reports => true ,
    :project_reports => true ,
    :category_reports => true 
  },
  :projects => {
    :search => true 
  },
  :categories => {
    :search => true 
  }
}

data_entry_role = Role.create!(
  :name        => ROLE_NAME[:data_entry],
  :title       => 'Data Entry',
  :description => 'Role for data_entry',
  :the_role    => role.to_json
)



# if Rails.env.development?

  admin = User.create_main_user(  :name => "Admin", :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  admin = User.create_main_user(  :name => "Admin2", :email => "admin2@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user
  
  admin = User.create_main_user(  :name => "Admin4", :email => "admin4@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  
   item_array = [] 
  (1..3).each do |x|
    item = Item.create_object(
      :sku => "SKU #{x}",
      :description => "Awesome description #{x}"
    )
    
    item_array << item 
  end
  
  puts "Total item: #{Item.count}"
  
  
  contact_array = [] 
  (1..3).each do |x|
    contact = Contact.create_object(
      :name             => "Contact #{x}"           ,
      :description      => "Description #{x}"      ,
      :address          =>  "Address #{x}"        ,
      :shipping_address => "Shipping Address"
    )
    contact_array << contact 
  end
  
  
  puts "Total contact: #{Contact.count}"
  
  machine_array = [] 
  (1..3).each do |x|
    machine = Machine.create_object(
      :name             => "Name #{x}"           ,
      :description      => "Description #{x}"      ,
      :brand          =>  "Brand #{x}"        
    )
    machine_array << machine 
  end
  
  
  puts "Total machine: #{Machine.count}"
  
  Machine.all.each do |x|
    (1..3).each do |y|
      component = Component.create_object(
        :name => "Component Name #{x.id} - #{y}" ,
        :description => "Description #{x.id} - #{y}",
        :machine_id => x.id 
      )
    end
    
  end
  puts "Total component: #{Component.count}"
  
  Component.all.each do |x|
    Compatibility.create_object(
      :item_id => Item.first.id,
      :component_id => x.id 
    )
  end
  
  puts "Total compatibility: #{Compatibility.count}" 
  

  (1..3).each do |x|
    Warehouse.create_object(
      :name             => "Gudang #{x}"           ,
      :description      => "Description #{x}"       
    )
  end
  
  puts "Total warehouse: #{Warehouse.count}" 
  
  (1..3).each do |x|
    StockAdjustment.create_object(
      :adjustment_date             => DateTime.now - 2.days         ,
      :description      => "description stock adjustment #{x}"      ,
      :warehouse_id => Warehouse.first.id 
    )
  end
  
  puts "Total stock adjustment: #{StockAdjustment.count}" 
  
  item_array  = Item.all 
  StockAdjustment.all.each do |sa|
    (1..3).each do |x|
      StockAdjustmentDetail.create_object(
        :item_id => item_array[x-1].id,
        :quantity => 10, 
        :stock_adjustment_id => sa.id 
      )
    end
  end
  
  puts "Total stock adjustment detail: #{StockAdjustmentDetail.count}"
  