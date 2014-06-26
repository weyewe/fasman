class ContractItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :customer
  belongs_to :contract_maintenance 
  
  validates_presence_of :item_id, :customer_id, :contract_maintenance_id
  
  def self.create_object( params ) 
    new_object           = self.new
    

    new_object.contract_maintenance_id    = params[:contract_maintenance_id]   
    new_object.customer_id                = params[:customer_id]
    new_object.item_id                    = params[:item_id    ]
    new_object.save

    return new_object
  end




  def update_object(params)
    self.contract_maintenance_id       = params[:contract_maintenance_id] 
    self.customer_id                   = params[:customer_id]
    self.item_id                       = params[:item_id    ]
    
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
