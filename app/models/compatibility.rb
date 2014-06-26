
class Compatibility < ActiveRecord::Base
  
  validates_presence_of :item_id, :component_id
  belongs_to :item
  belongs_to :component 
  
  
  validate :unique_item_id_component_combination
  
  
  def unique_item_id_component_combination
    return if not ( item_id.present? and component_id.present? )
    
    compatibility_count = self.class.where(
      :item_id => self.item_id,
      :component_id => self.component_id
    ).count
    
    if self.persisted? 
      if compatibility_count > 1 
        self.errors.add(:generic_errors, "Sudah ada kompatibilitas seperti ini")
        return self 
      end
    elsif compatibility_count > 0 
      self.errors.add(:generic_errors, "Sudah ada kompatibilitas seperti ini")
      return self
    end
  end
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.item_id            = params[:item_id] 
    new_object.component_id            = params[:component_id]
     
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.item_id  = params[:item_id]
    self.component_id      = params[:component_id    ]
    self.save
    
    return self
  end
  
  def delete_object
    
    # check if there is maintenance_detail using this compatibility
    
    self.destroy  
    
  end 
  
  
  def self.active_objects
    self
  end
end
