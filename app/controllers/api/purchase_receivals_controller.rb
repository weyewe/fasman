class Api::PurchaseReceivalsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = PurchaseReceival.active_objects.joins(:purchase_order, :warehouse).where{
        (
          (description =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = PurchaseReceival.active_objects.where{
        (
          (description =~  livesearch ) 
        )
        
      }.count
    else
      @objects = PurchaseReceival.active_objects.joins(:purchase_order, :warehouse).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = PurchaseReceival.active_objects.count
    end
    
    
    
    # render :json => { :purchase_receivals => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:purchase_receival][:receival_date] = parse_date_from_client_booking( params[:purchase_receival][:receival_date] ) 
    @object = PurchaseReceival.create_object( params[:purchase_receival] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_receivals => [
                            :id              =>  @object.id             , 
                            :purchase_order_id => @object.purchase_order_id, 
                            :receival_date =>  format_date_friendly( @object.receival_date )  ,  
                            :warehouse_id    =>  @object.warehouse_id   , 
                            :warehouse_name  =>  @object.warehouse.name , 
                            :is_confirmed    =>  @object.is_confirmed   ,  
                            :is_deleted      =>  @object.is_deleted     , 
                            :description     =>  @object.description    ,       
                            
                            :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                          ] , 
                        :total => PurchaseReceival.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    
    params[:purchase_receival][:receival_date] = parse_date( params[:purchase_receival][:receival_date] )
    params[:purchase_receival][:confirmed_at] = parse_date( params[:purchase_receival][:confirmed_at] ) 
    
    @object = PurchaseReceival.find_by_id params[:id] 
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :purchase_receivals, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm_object(:confirmed_at => params[:purchase_receival][:confirmed_at] )
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :purchase_receivals, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm_object 
    else
      @object.update_object(params[:purchase_receival])
    end
     
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_receivals => [
                          :id              =>  @object.id             , 
                          :purchase_order_id => @object.purchase_order_id, 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :receival_date =>  format_date_friendly( @object.receival_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )

                          ],
                        :total => PurchaseReceival.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end
  
  def show
    @object = PurchaseReceival.find_by_id params[:id] 
    render :json => { :success => true, 
                      :purchase_receivals => [
                          :id              =>  @object.id             , 
                          :warehouse_id    =>  @object.warehouse_id   , 
                          :warehouse_name  =>  @object.warehouse.name , 
                          :purchase_order_id  =>  @object.purchase_order_id , 
                          :is_confirmed    =>  @object.is_confirmed   ,  
                          :is_deleted      =>  @object.is_deleted     , 
                          :description     =>  @object.description    ,       
                          :receival_date =>  format_date_friendly( @object.receival_date )  ,  
                          :confirmed_at    =>  format_date_friendly( @object.confirmed_at )
                        	
                        	
                        ] , 
                      :total => PurchaseReceival.active_objects.count }
  end

  def destroy
    @object = PurchaseReceival.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => PurchaseReceival.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = PurchaseReceival.active_objects.where{ (description =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = PurchaseReceival.active_objects.where{ (description =~ query)  
                              }.count
    else
      @objects = PurchaseReceival.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = PurchaseReceival.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
