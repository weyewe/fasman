class Customer < ActiveRecord::Base
  attr_accessible :name, :address, :email  
   
  validates_presence_of :name  
  validates_uniqueness_of :name 
  has_many :items
  has_many :contract_maintenances
  
 
  
  def self.create_object( params ) 
    new_object           = self.new
    new_object.name    =  ( params[:name].present? ? params[:name   ].to_s.upcase : nil )  
    new_object.address  = params[:address]
    new_object.pic      = params[:pic    ]
    new_object.contact  = params[:contact]
    new_object.email    = params[:email  ] 
    new_object.save
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    self.name    =  ( params[:name].present? ? params[:name   ].to_s.upcase : nil  ) 
    self.address  = params[:address]
    self.pic      = params[:pic    ]
    self.contact  = params[:contact]
    self.email    = params[:email  ] 
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
