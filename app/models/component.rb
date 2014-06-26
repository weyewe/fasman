
class Component < ActiveRecord::Base
  validates_presence_of :name, :machine_id 
  validates_uniqueness_of :name 
  
  has_many :components, :through => :compatibilities 
  has_many :compatibilities 
  
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.name            = params[:sku] 
    new_object.description            = params[:description]
    new_object.machine_id            = params[:machine_id]
     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.sku  = params[:sku]
    self.description      = params[:description    ]
    self.machine_id      = params[:machine_id    ]
    self.save
    
    return self
  end
  
  def delete_object
    
    if self.maintenance_details.count != 0 
      self.errors.add(:generic_errors, "Sudah ada maintenance untuk komponen ini")
      return self 
    end
    
    self.destroy 
    
  end 
  
  
  def self.active_objects
    self 
  end
end
