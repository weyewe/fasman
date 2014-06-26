=begin
  A company has_many ContractMaintenances 
  
  Company A :
  1. contract 1: maintain network ,starting from 30 April
  2. contract 2: maintain PC, starting from 5 May
  3. contract 3: maintain DB, strai
  
=end


=begin
  A company has many items. 
  
  Those items can be under our maintenance. 
  However, not all items are under contract maintenance. 
  
  Item has_many Items 
  
  Item has_many MaintenanceContracts 
  
  MaintenanceContract has_many Items through ContractedItem 

  
  
=end
class ContractMaintenance < ActiveRecord::Base
   
  
   
  validates_presence_of :customer_id, :description, :name    
  belongs_to :customer 
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.customer_id            = params[:customer_id]
    new_object.description                = params[:description    ]
    new_object.name            = params[:name]
    new_object.started_at        = params[:started_at]
    new_object.finished_at  = params[:finished_at]
     
    
    if new_object.save
      
      now = DateTime.now
      year = now.year
      month = now.month 
      
      
      beginning_of_the_year_datetime = now.beginning_of_year
      end_of_the_year_datetime = (now + 1.year).beginning_of_year - 1.second
      
      total_item_created_in_current_year = new_object.customer.contract_maintenances.where(
        :created_at => beginning_of_the_year_datetime..end_of_the_year_datetime
      ).count 
      
      new_object.code = "#{year}/#{new_object.customer_id}/#{total_item_created_in_current_year}"
      new_object.save 
    end
    
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.customer_id            = params[:customer_id]
    self.description                = params[:description    ]
    self.name            = params[:name]
    self.started_at        = params[:started_at]
    self.finished_at  = params[:finished_at]
    
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
