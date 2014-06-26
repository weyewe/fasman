class Maintenance < ActiveRecord::Base
  
  # Complaint => DIagnosis => Solution 
  attr_accessible :name, :address, :email  
   
  validates_presence_of :customer_id, :item_id, :user_id 
  belongs_to :item
  belongs_to :customer 
  belongs_to :user
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.item_id        = params[:item_id]
    new_object.customer_id    = params[:customer_id    ]
    new_object.user_id        = params[:user_id]
    new_object.complaint_date   = params[:complaint_date  ] 
    new_object.complaint      = params[:complaint  ] 
    new_object.complaint_case = params[:complaint_case]
    
    
    if new_object.save
      
      now = DateTime.now
      year = now.year
      month = now.month 
      
      beginning_of_the_month_datetime = now.beginning_of_month
      end_of_the_month_datetime = (now + 1.month).beginning_of_month - 1.second
      
      total_maintenance_created_in_current_month = new_object.class.where(
        :created_at => beginning_of_the_month_datetime..end_of_the_month_datetime
      ).count 
      
      new_object.code = "#{year}/#{month}/#{new_object.customer_id}/#{total_maintenance_created_in_current_month}"
      new_object.save 
    end
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    self.item_id        = params[:item_id]
    self.user_id        = params[:user_id]
    self.complaint_date   = params[:complaint_date  ] 
    self.complaint      = params[:complaint  ] 
    self.complaint_case = params[:complaint_case]

    self.save
    
    
    return self
  end
  
  def delete_object
    
    if self.is_diagnosed?  
      self.errors.add(:generic_errors, "Sudah ada diagnosa")
      return self 
    end
    
    self.is_deleted  = true 
    self.save  
    
    
    return self 
  end 
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
  def complaint_case_text
    return "" if not  complaint_case.present? 
    
    return "Scheduled" if complaint_case == MAINTENANCE_CASE[:scheduled]
    return "Emergency" if complaint_case == MAINTENANCE_CASE[:emergency]  
  end
  
  def diagnosis_case_text
    return "" if not diagnosis_case.present? 
    
   
    
    return "OK" if diagnosis_case == DIAGNOSIS_CASE[:all_ok]
    return "Butuh Perbaikan" if diagnosis_case == DIAGNOSIS_CASE[:require_fix]
    return "Butuh Penggantian" if diagnosis_case == DIAGNOSIS_CASE[:require_replacement]
  end
  
  def solution_case_text
    return "" if not solution_case.present? 
   
    return "Normal" if solution_case == SOLUTION_CASE[:normal]
    return "Pending" if solution_case == SOLUTION_CASE[:pending]
    return "Solved" if solution_case == SOLUTION_CASE[:solved]
  end
  
=begin
Phase related
=end

  def validate_diagnosis 
    if not diagnosis_case.present?
      self.errors.add(:diagnosis_case, "Harus ada")
      return self 
    end
     
    if not [
        DIAGNOSIS_CASE[:all_ok],
        DIAGNOSIS_CASE[:require_fix],
        DIAGNOSIS_CASE[:require_replacement],
      ].include?( self.diagnosis_case)
      self.errors.add(:diagnosis_case, "Tidak valid")
      return self 
    end
  end
  
  def diagnose(params)
    self.is_diagnosed = true 
    self.diagnosis_case = params[:diagnosis_case]
    self.diagnosis = params[:diagnosis] 
    self.diagnosis_date = params[:diagnosis_date]
    
    
    self.validate_diagnosis
    return self if self.errors.size != 0
    self.save 
    
    
    
    return self 
  end
  
  def undiagnose( params ) 
    if self.is_solved?
      self.errors.add(:generic_errors, "Sudah di solve")
      return self 
    end
    
    
    self.is_diagnosed = false
    self.diagnosis_case = nil
    self.diagnosis = nil 
    self.diagnosis_date = nil 
    
    
    self.save
  end
  
  
  def validate_solve
    if not solution_case.present?
      self.errors.add(:solution_case, "Harus ada")
      return self 
    end
     
    if not [
        SOLUTION_CASE[:normal],
        SOLUTION_CASE[:pending],
        SOLUTION_CASE[:solved],
      ].include?( self.solution_case)
      self.errors.add(:solution_case, "Tidak valid")
      return self 
    end
  end
  
  def solve(params)
    if not self.is_diagnosed?
      self.errors.add(:generic_errors, "Belum di diagnosa")
      return self 
    end
    
    self.is_solved = true 
    self.solution_case = params[:solution_case]
    self.solution = params[:solution]
    self.solution_date =  params[:solution_date] 
    self.validate_solve
    
    return self if self.errors.size != 0
    
    self.save 
  end
  
  def unsolve( params ) 
    if not self.is_solved? 
      self.errors.add(:generic_errors, "Belum di solve")
      return self 
    end
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi")
      return self 
    end
    
    
    self.is_solved = false
    self.solution_case = nil
    self.solution = nil 
    self.save 
    
  end
  
  def confirm( params ) 
    if not self.is_solved?
      self.errors.add(:generic_errors, "Belum di solve")
      return self 
    end
    
    self.is_confirmed = true 
    self.save 
  end
  
  def unconfirm(params)
    if not self.is_confirmed?
      self.errors.add(:generic_errors, "Belum di konfirmasi")
      return self 
    end
    
    self.is_confirmed = false 
    self. save
  end
end
