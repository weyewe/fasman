
class Asset < ActiveRecord::Base
  validates_presence_of :machine_id, :customer_id, :code 
  validates_uniqueness_of :code
  
  belongs_to :customer
  belongs_to :machine 
  has_many :maintenances
  has_many :asset_details 
  
  
  validate :machine_component_has_been_created
  
  
  def machine_component_has_been_created
    return if not self.machine_id.present? 
    return if self.persisted? 
    
    if self.machine.components.count == 0 
      self.errors.add(:generic_errors, "There is no component registered in the machine")
      return self 
    end
  end
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.machine_id            = params[:machine_id] 
    new_object.customer_id            = params[:customer_id] 
    new_object.description            = params[:description]
    new_object.code = params[:code]
    if new_object.save
      new_object.machine.components.each do |component|
        AssetDetail.create_object(
          :component_id => component.id,
          :asset_id => new_object.id
        )
      end
    end
      
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.customer_id = params[:customer_id]
    self.description      = params[:description    ]
    self.code = params[:code]
    self.save
    
    return self
  end
  
  def delete_object
    if self.components.count != 0 
      self.errors.add(:generic_errors, "Sudah ada komponen")
      return self 
    end
    
    if self.maintenances.count != 0 
      self.errors.add(:generic_errors, "sudah ada maintenance")
      return self 
    end
    
    
    
    self.asset_details.each {|x| x.destroy }
    self.destroy 
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
  def all_details_initialized?
    return true if self.asset_details.where{
                            initial_item_id.eq nil
                          }.count == 0  
                          
    return false  
  end
end