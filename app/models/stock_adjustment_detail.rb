class StockAdjustmentDetail < ActiveRecord::Base
  belongs_to :stock_adjustment
  belongs_to :item 
  
  validates_presence_of :quantity, :item_id, :stock_adjustment_id 
  
  validate :non_zero_quantity
  validate :non_negative_final_quantity
  
  def non_zero_quantity
    return if not quantity.present? 
    if quantity == 0 
      self.errors.add(:quantity, "Tidak boleh 0 ")
      return self 
    end
  end
  
  def non_negative_final_quantity
    return if not item.present? 
    return if not quantity.present?
    
    initial_quantity = item.ready
    additional_quantity = quantity
    final_quantity = additional_quantity + initial_quantity
    
    if final_quantity  < 0 
      self.errors.add(:quantity, "Jumlah akhir tidak boleh negative")
      return self 
    end
     
  end
   
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.stock_adjustment_id = params[:stock_adjustment_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    new_object.save 
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    self.save
  end
   
  
  
  
  def delete_object
    if not self.stock_adjustment.is_confirmed?
      self.destroy 
    else
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
  end
  
  
  
  def confirmable? 
    return false if self.stock_adjustment.is_confirmed?
    
    self.non_negative_final_quantity
    return false if self.errors.size != 0  
    
    
    return true
  end
  
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    item.ready += self.quantity
    item.save 
     
  end
  
  def unconfirmable?
    return false if not self.is_confirmed? 
    
    final_quantity = item.ready + -1*self.quantity
    if final_quantity < 0 
      self.errors.add(:generic_errors, "Kuantitas akhir tidak boleh negative")
      return false 
    end 
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    item.ready += -1* self.quantity 
    item.save 
  end
  
   
end
