require 'spec_helper'

describe Asset do
  before(:each) do
    @machine = Machine.create_object(
      :name => "34242wafaw",
      :brand => "Yokoko",
      :description => "awesome machine"
    )
    @item1 = Item.create_object(
      :sku => "34242wafaw",
      :description => "awesome item"
    )
    
    @item2 = Item.create_object(
      :sku => "aa34242wafaw",
      :description => "awesome item2"
    )
    
    @component = Component.create_object(
      :machine_id => @machine.id,
      :name => "name 1234",
      :description => "Awesome component"
    )
    
    
    @compa1 = Compatibility.create_object(
      :component_id => @component.id,
      :item_id => @item1.id 
    )
    
    
    @customer = Customer.create_object(
      :name     => "Awesome Custom",
      :address  => "address",
      :pic      => "andi sitorus",
      :contact  => "9348820423",
      :email    => "andi.sitorus@gmail.com"
    )
    
  end 
  
  it "should be allowed to create asset" do
    asset = Asset.create_object(
      :machine_id  => @machine.id, 
      :customer_id => @customer.id,
      :description =>  "Awesome asset",
      :code        =>  "382yuekljwf"
    )
    
    asset.should be_valid 
  end
  
  context "created asset" do
    before(:each) do
      @asset = Asset.create_object(
        :machine_id  => @machine.id, 
        :customer_id => @customer.id,
        :description =>  "Awesome asset",
        :code        =>  "382yuekljwf"
      )
    end
    
    it "should automatically create part" do
      @asset.asset_details.count.should == 1 
      
      @asset.asset_details.first.component_id.should == @component.id 
    end
    
    context "adding new component to the machine" do
      before(:each) do
        @component2 = Component.create_object(
          :machine_id => @machine.id,
          :name => "name 1234 aaa",
          :description => "Awesome component extra"
        )
        
        @asset.reload 
      end
      
      it "should automatically create asset_part" do
        @asset.asset_details.count.should == 2 
        @asset.asset_details.order("id DESC").first.component_id.should == @component2.id 
      end
      
    end
  end
  
end
