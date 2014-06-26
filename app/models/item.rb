=begin
  A company has many items. 
  
  Those items can be under our maintenance. 
  However, not all items are under contract maintenance. 
  
  Item has_many Items 
  
  Item has_many MaintenanceContracts 
  
  MaintenanceContract has_many Items through ContractedItem 

  
  
=end
class Item < ActiveRecord::Base
   
  validates_presence_of :customer_id, :item_type_id   
  belongs_to :customer
  belongs_to :item_type 
  
  validate :valid_item_type_id
  
  def valid_item_type_id
    return if not  self.item_type_id.present? 
    
    object  = ItemType.find_by_id self.item_type_id
    if object.nil?
      self.errors.add(:item_type_id, "Harus ada")
      return self 
    end
  end
  
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.customer_id            = params[:customer_id]
    new_object.item_type_id                = params[:item_type_id    ]
    
    new_object.description            = params[:description]
    new_object.manufactured_at        = params[:manufactured_at]
    new_object.warranty_expiry_date  = params[:warranty_expiry_date]
     
    
    if new_object.save
      
      now = DateTime.now
      year = now.year
      month = now.month 
      
      
      beginning_of_the_year_datetime = now.beginning_of_year
      end_of_the_year_datetime = (now + 1.year).beginning_of_year - 1.second
      
      total_item_created_in_current_year = new_object.customer.items.where(
        :created_at => beginning_of_the_year_datetime..end_of_the_year_datetime
      ).count 
      
      new_object.code = "#{year}/#{month}/#{new_object.customer_id}/#{total_item_created_in_current_year}"
      new_object.save 
    end
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.customer_id  = params[:customer_id]
    self.item_type_id      = params[:item_type_id    ]
    
    self.description  = params[:description]
    self.manufactured_at  = params[:manufactured_at]
    self.warranty_expiry_date  = params[:warranty_expiry_date] 
    
    self.save
    
    return self
  end
  
  def delete_object
    
    
    
    self.is_deleted  = true 
    self.save  
    
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end
