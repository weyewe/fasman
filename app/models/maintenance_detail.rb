
class MaintenanceDetail < ActiveRecord::Base
  validates_presence_of :maintenance_id  
  validates_presence_of :component_id  
  
  belongs_to :maintenance
  belongs_to :component  
  
  validate :maintenance_is_not_confirmed_upon_save
  
  def maintenance_is_not_confirmed_upon_save
    return if maintenance_id.nil?
    
    if maintenance.is_confirmed?
      self.errors.add(:generic_errors, "maintenance sudah di konfirmasi")
      return self 
    end
  end
 
  
  def self.create_object( params ) 
    new_object           = self.new
    
    


    new_object.maintenance_id = params[:maintenance_id] 
    new_object.component_id   = params[:component_id] 
    
    new_object.save 
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    # self.asset_id            = params[:asset_id] 
    # self.complaint_date            = params[:complaint_date] 
    # self.complaint            = params[:complaint]
    # self.complaint_case            = params[:complaint_case]
    # self.save
    # 
    # return self
  end
  
  
  def validate_update_maintenance_result
    return true
  end
  
  def update_maintenance_result( params ) 
    
    if self.maintenance.is_confirmed?
      self.errors.add(:generic_errors, "Maintenance sudah di konfirmasi")
      return self 
    end
    
    self.diagnosis                  =  self.diagnosis
    self.diagnosis_case             =  self.diagnosis_case          
    self.solution                   =  self.solution                
    self.solution_case              =  self.solution_case            
    self.is_replacement_required    =  self.is_replacement_required 
    self.replacement_item_id        =  self.replacement_item_id     
    
    self.validate_update_maintenance_result 
    
    if self.errors.size == 0 
      self.save
    end
    
    return self 
  end
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self
    end
    
    if self.is_deleted?
      self.errors.add(:generic_errors, "Sudah delete")
      return self 
    end
    
    if self.components.count != 0 
      self.errors.add(:generic_errors, "Sudah ada komponen")
      return self 
    end
    
    self.destroy
  end 
  
  def confirm(params)
    self.save 
  end
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end