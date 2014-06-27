
class Asset < ActiveRecord::Base
  validates_presence_of :machine_id, :customer_id, :code 
  validates_uniqueness_of :code
  
  belongs_to :customer
  belongs_to :machine 
  has_many :maintenances
  has_many :asset_details 
  
 
  
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
    
    
    
    self.is_deleted = true 
    self.save  
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end