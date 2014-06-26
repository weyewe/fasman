=begin
  A company has many items. 
  
  Those items can be under our maintenance. 
  However, not all items are under contract maintenance. 
  
  Item has_many Items 
  
  Item has_many MaintenanceContracts 
  
  MaintenanceContract has_many Items through ContractedItem 

  
  
=end
class Item < ActiveRecord::Base
  validates_uniqueness_of :sku
  
  has_many :components, :through => :compatibilities 
  has_many :compatibilities 
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.sku            = params[:sku] 
    new_object.description            = params[:description]
     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.sku  = params[:sku]
    self.description      = params[:description    ]
    self.save
    
    return self
  end
  
  def delete_object
    
    # check if there is stock mutations. if yes, return false , don't delete
    
    self.is_deleted  = true 
    self.save  
    
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end
