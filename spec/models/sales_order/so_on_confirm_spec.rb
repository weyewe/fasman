require 'spec_helper'

describe SalesOrderDetail do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
    
    @item2 = Item.create_object(
    :sku            => sku + "32424",
    :description    => description, 
    :standard_price => standard_price
    )
    
    @contact = Contact.create_object(
      :name             => "Contact"           ,
      :description      => "Description"      ,
      :address          =>  "Address"        ,
      :shipping_address => "Shipping Address"
    )
    
    @so = SalesOrder.create_object(
      :sales_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @discount = 0
    @unit_price  = BigDecimal("1500")
    
    @so_detail = SalesOrderDetail.create_object(
      :sales_order_id  => @so.id       ,
      :item_id            => @item.id     ,
      :quantity           => @quantity    ,
      :discount           => @discount    ,
      :unit_price         => @unit_price
    )
  end
  
  it "should be confirmable" do
    @so.confirm_object(:confirmed_at => DateTime.now )
    
    @so.errors.size.should == 0 
    @so.should be_valid 
  end
  
  context "confirmed purchase order" do
    before(:each) do
      @item.reload
      @initial_item_pending_delivery = @item.pending_delivery
      @so.confirm_object(:confirmed_at => DateTime.now )
      @so.reload
      @so_detail.reload
      @item.reload 
    end
    
    it "should increase pending receival" do
      @final_item_pending_delivery = @item.pending_delivery
      
      diff = @final_item_pending_delivery - @initial_item_pending_delivery
      diff.should == @quantity 
      
    end
    
    it "should create a stock mutation" do
    
       
       stock_mutation_list = StockMutation.where(
        :item_id => @item.id,
        :source_document_detail_id => @so_detail.id , 
        :source_document_detail => @so_detail.class.to_s 
       )
       
       stock_mutation_list.count.should ==1  
       
       stock_mutation = stock_mutation_list.first 
       
       stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
       stock_mutation.item_case.should == STOCK_MUTATION_ITEM_CASE[:pending_delivery]  
    end
    
  
    
    context "unconfirm sales order" do
      before(:each) do
        @so.reload 
        @item.reload
        @so_detail.reload 
        @initial_item_pending_delivery = @item.pending_delivery
        @so.unconfirm_object 
        @so.reload 
        @item.reload
        @so_detail.reload
      end
      
      it "should deduct item.pending_delivery" do
        @final_item_pending_delivery = @item.pending_delivery
        diff = @final_item_pending_delivery - @initial_item_pending_delivery
        diff.should == -1* @quantity
      end
      
      it "should destroy the stock mutation" do
        StockMutation.where(
          :item_id => @item.id,
          :source_document_detail_id => @so_detail.id , 
          :source_document_detail => @so_detail.class.to_s 
         ).count.should == 0 
      end
    end
  
  
    context "create  delivery to make the unconfirm action fail" do
      before(:each) do
        
        @do = DeliveryOrder.create_object(
          :delivery_date  => DateTime.new(2012,2,2,0,0,0),
          :description    => "Awesome purchase order",
          :sales_order_id     => @so.id 
        )
        
        @do_detail = DeliveryOrderDetail.create_object(
          :delivery_order_id         => @do.id       ,
          :sales_order_detail_id     => @so_detail.id     ,
          :quantity                     => @quantity
        )
        
        @do.confirm_object(:confirmed_at => DateTime.now)
        @so_detail.reload
        @so.reload 
      end
      
      it "should confirm pr" do
        @do.errors.size.should ==0  
        @do.is_confirmed.should be_true 
      end
      
      it "should not allow unconfirm in po_detail" do
        @so_detail.unconfirmable?.should be_false 
      end
      
      it "should not allow unconfirm in po level" do
        @so.unconfirm_object
        @so.is_confirmed.should be_true 
        @so.errors.size.should_not == 0 
      end
    end
  end
   

  
  
end
