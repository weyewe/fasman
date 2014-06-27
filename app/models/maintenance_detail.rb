
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
    puts "\n\nInside validate_update_maintenance_result"
    puts "inspection: #{self}"
    puts "diagnosis_case: #{self.diagnosis_case}"
    puts "solution_case: #{self.solution_case}"
    
    if is_replacement_required.present? and is_replacement_required?
      if not replacement_item_id.present?
        self.errors.add(:replacement_item_id, "harus ada")
      end
      
      replacement_item = Item.find_by_id replacement_item_id
      if replacement_item.nil?
        self.errors.add(:replacement_item_id, "harus ada") 
      end
    end
    
   
    
    if not diagnosis_case.present?
      self.errors.add(:diagnosis_case, "Harus ada")
    else
      if not [
        DIAGNOSIS_CASE[:all_ok],
        DIAGNOSIS_CASE[:require_fix],
        DIAGNOSIS_CASE[:require_replacement],
        ].include?(self.diagnosis_case)
        self.errors.add(:diagnosis_case, "Harus valid")
      end
    end
    
    if not solution_case.present?
      self.errors.add(:solution_case, "Harus ada")
    else
      if  not [
        SOLUTION_CASE[:pending],
        SOLUTION_CASE[:solved],
        ].include?(self.solution_case)
        self.errors.add(:solution_case, "Harus valid")
      end
    end
  end
  
  def update_maintenance_result( params ) 
    puts "The params: #{params}"
    
    if self.maintenance.is_confirmed?
      self.errors.add(:generic_errors, "Maintenance sudah di konfirmasi")
      return self 
    end
    
    self.diagnosis                  =  params[:diagnosis                ]
    self.diagnosis_case             =  params[:diagnosis_case           ]
    self.solution                   =  params[:solution                 ]
    self.solution_case              =  params[:solution_case            ]
    self.is_replacement_required    =  params[:is_replacement_required  ]
    self.replacement_item_id        =  params[:replacement_item_id      ]
    
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
  
  def confirmable?
     
  end
  
  
  def replacement_item
    Item.find_by_id self.replacement_item_id
  end
  
  def confirm 
    if is_replacement_required?
      selected_replacement_item = self.replacement_item
      selected_replacement_item.ready -= 1 
      selected_replacement_item.save 
    end
  end
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end