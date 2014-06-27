
class Maintenance < ActiveRecord::Base
  validates_presence_of :asset_id 
  validates_presence_of :complaint_date 
  
  belongs_to :asset 
  has_many :maintenance_details 
  
  
=begin
  Problem: what if there is uninitialized asset? Can't create maintenance. Easy. 
  
  But, what if such uninitalized asset detail is created after the maintenance is confirmed?
    Wont create maintenance detail for that asset detail
=end

  validate :all_asset_detail_initial_item_are_assigned
  
  def all_asset_detail_initial_item_are_assigned
    return if self.persisted?
    return if not asset_id.present? 
    
    if not asset.all_details_initialized?
      self.errors.add(:generic_errors, "Not all asset details are assigned. Ask Admin!")
      return self 
    end
    
  end
 
  
  def self.create_object( params ) 
    new_object                = self.new
    new_object.asset_id       = params[:asset_id] 
    new_object.complaint_date = params[:complaint_date] 
    new_object.complaint      = params[:complaint]
    new_object.complaint_case = params[:complaint_case]

     
    if new_object.save
      new_object.code  = ""
      new_object.save 
      
      new_object.asset.asset_details.each do |asset_detail|
        MaintenanceDetail.create_object(
         :maintenance_id => new_object.id, 
         :component_id   => asset_detail.component_id 
        )
      end
    end
    
    return new_object
  end
  
  
   
  
  def update_object(params)
    
    self.complaint_date = params[:complaint_date] 
    self.complaint      = params[:complaint]
    self.complaint_case = params[:complaint_case]

    self.save
    
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
    
    
    
    self.is_deleted = true 
    self.save  
  end 
  
  def confirm(params)
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self 
    end
    
    if self.is_deleted?
      self.errors.add(:generic_errors, "Sudah delete")
      return self 
    end
    
    
    if self.maintenance_details.count != 0 
      self.errors.add(:generic_errors, "Tidak ada maintenance detail")
      return self 
    end
    
    replacement_required_maintenance_details = self.maintenance_details.where(:is_replacement_required => true )
    
    if replacement_required_maintenance_details.count != 0 
      all_possible_id_array = replacement_required_maintenance_details.map{|x| x.replacement_item_id }
      all_possible_id_array.uniq!
      hash = {} 
      all_possible_id_array.each do |replacement_item_id|
        count = replacement_required_maintenance_details.where(:replacement_item_id => replacement_item_id).count
        hash[replacement_item_id] = count
      end
      
      hash.each do |key,value|
        item = Item.find_by_id key 
        if item.ready  < value
          self.errors.add(:generic_errors, "Tidak cukup item #{item.sku}")
          return self 
        end
      end
    end
    
     
    
    replacement_required_maintenance_details.each do |maintenance_detail|
      maintenance_detail.confirm 
    end
    
    
    self.is_confirmed = true 
    self.confirmed_at = params[:confirmed_at ]
    
    self.save 
    
    
  end
  
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end