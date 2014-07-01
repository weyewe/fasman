require 'spec_helper'

describe DeliveryOrderDetail do
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
      :description    => "Awesome sales order",
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
    @so.confirm_object(:confirmed_at => DateTime.now)
    

  end
  
  it "should confirm PO" do
    @so.is_confirmed.should be_true 
  end
  
  context "creating delivery order" do
    before(:each) do
      @item.reload 
      @initial_pending_delivery = @item.pending_delivery
      @initial_ready = @item.ready
      
      @do = DeliveryOrder.create_object(
         :delivery_date  => DateTime.new(2012,2,2,0,0,0),
         :description    => "Awesome sales order",
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
       @item.reload 
    end
    
    it "should reduce pending delivery" do
      @final_pending_delivery = @item.pending_delivery
      diff = @final_pending_delivery - @initial_pending_delivery
      diff.should == -1 * @quantity 
    end
    
    it "should reduce ready stock" do
      @final_ready = @item.ready
      diff = @final_ready - @initial_ready
      diff.should == -1 * @quantity
    end
    
    it "should create 2 stock mutations " do
      stock_mutation_list = StockMutation.where(
        :item_id => @item.id,
        :source_document_detail_id => @do_detail.id , 
        :source_document_detail => @do_detail.class.to_s 
       )
       
       stock_mutation_list.count.should == 2 
       
       pending_delivery_stock_mutation = stock_mutation_list.where(:item_case => STOCK_MUTATION_ITEM_CASE[:pending_delivery]  ).first
       ready_stock_mutation = stock_mutation_list.where(:item_case => STOCK_MUTATION_ITEM_CASE[:ready]  ).first
       pending_delivery_stock_mutation.should be_valid
       ready_stock_mutation.should be_valid 
       
       pending_delivery_stock_mutation.case.should == STOCK_MUTATION_CASE[:deduction]
       ready_stock_mutation.case.should == STOCK_MUTATION_CASE[:deduction]
    end
    
    
    
    context "unconfirm delivery order" do
      before(:each) do
        @item.reload 
        @initial_pending_delivery = @item.pending_delivery
        @initial_ready = @item.ready

       
         @do.unconfirm_object 
         @so_detail.reload
         @so.reload
         @item.reload
         @do.reload 
      end
      
      it "should unconfirm the do" do
        @do.is_confirmed.should be_false 
      end
      
      it "should increase pending delivery" do
        @final_pending_delivery = @item.pending_delivery
        diff = @final_pending_delivery - @initial_pending_delivery
        diff.should == 1 * @quantity
      end
      
      it "should increase ready stock" do
        @final_ready = @item.ready
        diff = @final_ready - @initial_ready
        diff.should == 1*@quantity
      end
      
      it "should have no stock mutations " do
        StockMutation.where(
          :item_id => @item.id,
          :source_document_detail_id => @do_detail.id , 
          :source_document_detail => @do_detail.class.to_s 
         ).count.should ==0 
      end
    end
  
  
  end
  

  
  
end