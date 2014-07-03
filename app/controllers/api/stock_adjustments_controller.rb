class Api::StockAdjustmentsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = StockAdjustment.active_objects.where{
        (
          (description =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = StockAdjustment.active_objects.where{
        (
          (description =~  livesearch ) 
        )
        
      }.count
    else
      @objects = StockAdjustment.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = StockAdjustment.active_objects.count
    end
    
    
    
    # render :json => { :stock_adjustments => @objects , :total => @total, :success => true }
  end

  def create
    @object = StockAdjustment.create_object( params[:stock_adjustment] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :stock_adjustments => [@object] , 
                        :total => StockAdjustment.active_objects.count }  
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
    
    @object = StockAdjustment.find_by_id params[:id] 
    @object.update_object( params[:stock_adjustment])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :stock_adjustments => [@object],
                        :total => StockAdjustment.active_objects.count  } 
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

  def destroy
    @object = StockAdjustment.find(params[:id])
    @object.delete_object

    if not @object.persisted?
      render :json => { :success => true, :total => StockAdjustment.active_objects.count }  
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
      @objects = StockAdjustment.active_objects.where{ (description =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = StockAdjustment.active_objects.where{ (description =~ query)  
                              }.count
    else
      @objects = StockAdjustment.active_objects.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = StockAdjustment.active_objects.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
