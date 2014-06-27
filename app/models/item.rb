
class Item < ActiveRecord::Base
  validates_uniqueness_of :sku
  
  has_many :components, :through => :compatibilities 
  has_many :compatibilities 
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    
    new_object.sku    =  ( params[:sku].present? ? params[:sku   ].to_s.upcase : nil )  
    
    new_object.description            = params[:description]
     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.sku  =  ( params[:sku].present? ? params[:sku   ].to_s.upcase : nil )  
    self.description      = params[:description    ]
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
