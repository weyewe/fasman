require 'spec_helper'

describe StockAdjustment do
  before(:each) do
    @item1 = Item.create_object(
      :sku => "34242wafaw",
      :description => "awesome item"
    )
    
    @item2 = Item.create_object(
      :sku => "2234242wafaw",
      :description => "awesome item 22"
    )
  end
  
  it "should create 2 items" do
    Item.count.should ==  2
  end
  
  context "creating stock adjustment " do
    before(:each) do
      @stock_adjustment = StockAdjustment.create_object(
        :adjustment_date  => DateTime.now , 
        :description      => "awesome adjustment "
      )
    end
    
    it "should create valid stock_adjustment" do
      @stock_adjustment.should be_valid 
    end
    
    it "should not allow confirmation" do 
      @stock_adjustment.confirm_object(
        :confirmed_at => DateTime.now + 2.days 
      )
      
      @stock_adjustment.errors.size.should_not == 0 
      @stock_adjustment.reload 
      @stock_adjustment.is_confirmed.should be_false 
    end
  end
end
