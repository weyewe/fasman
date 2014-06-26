class Api::MaintenancesController < Api::BaseApiController
  
  def index
    
    
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Maintenance.active_objects.where{ 
        (
          (name =~  livesearch ) | 
          (code =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Maintenance.active_objects.where{ 
        (
          (name =~  livesearch ) | 
          (code =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      # @group_loan = Maintenance.find_by_id params[:parent_id]
      @objects = Maintenance.active_objects.
                  where(:customer_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Maintenance.active_objects.where(:customer_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    
    
    
    
    # render :json => { :items => @objects , :total => @total, :success => true }
  end

  def create
    
    params[:maintenance][:complaint_date] =  parse_datetime_from_client_booking( params[:maintenance][:complaint_date] )
    params[:maintenance][:diagnosis_date] =  parse_datetime_from_client_booking( params[:maintenance][:diagnosis_date] )
    params[:maintenance][:solution_date] =  parse_datetime_from_client_booking( params[:maintenance][:solution_date] )
    
    
    @object = Maintenance.create_object( params[:maintenance] )  
    
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :maintenances => [
                          :id 							=>  	@object.id    ,
                        	:item_name 			 										 =>   @object.item.code                                ,
                        	:item_id                   => @object.item.id , 
                        	:customer_name 						 =>   @object.customer.name  ,
                        	:customer_id					 =>   @object.customer.id   ,
                        	:user_id             =>   @object.user.id , 
                        	:user_name 										 =>   @object.user.name,
                        	:complaint_date 										 =>   format_date_friendly(@object.complaint_date)    ,
                        	:complaint 							 =>   @object.complaint ,
                        	:complaint_case 									 =>    @object.complaint_case ,
                        	:complaint_case_text 											 =>   @object.complaint_case_text,
                        	:diagnosis_date 											 =>   format_date_friendly( @object.diagnosis_date )   ,
                        	:diagnosis =>   @object.diagnosis     ,
                          :diagnosis_case =>   @object.diagnosis_case,                            # 
                          :diagnosis_case_text                               => @object.diagnosis_case_text,
                          :is_diagnosed   => @object.is_diagnosed,
                          :solution_date                           =>  format_date_friendly( @object.solution_date ),
                          :solution      => @object.solution ,
                        	:solution_case => @object.solution_case,
                        	:solution_case_text => @object.solution_case_text,
                        	:is_solved => @object.is_solved,
                        	:is_confirmed => @object.is_confirmed,
                          :is_deleted => @object.is_deleted
                          ] , 
                        :total => Maintenance.active_objects.count }  
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
    @object = Maintenance.find(params[:id])
    
    
    params[:maintenance][:complaint_date] =  parse_datetime_from_client_booking( params[:maintenance][:complaint_date] )
    params[:maintenance][:diagnosis_date] =  parse_datetime_from_client_booking( params[:maintenance][:diagnosis_date] )
    params[:maintenance][:solution_date] =   parse_datetime_from_client_booking( params[:maintenance][:solution_date] )


    if params[:diagnosis].present?  
      if not current_user.has_role?( :maintenances, :diagnose)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      
      @object.diagnose(  params[:maintenance]  )
    elsif params[:solution].present?    
      
      if not current_user.has_role?( :maintenances, :undiagnose)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.undiagnose 
      
    elsif params[:solve].present?
      if not current_user.has_role?( :maintenances, :solve)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.solve(   params[:maintenance]  )
    elsif params[:unsolve].present?  
      if not current_user.has_role?( :maintenances, :unsolve)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
        
      @object.unsolve
    elsif params[:confirm].present?
      if not current_user.has_role?( :maintenances, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.confirm 
    elsif params[:unconfirm].present?
      if not current_user.has_role?( :maintenances, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.unconfirm 
    else
    
      @object.update_object(params[:maintenance])
    end
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :maintenances => [
                            :id 							=>  	@object.id    ,
                          	:item_name 			 										 =>   @object.item.code                                ,
                          	:item_id                   => @object.item.id , 
                          	:customer_name 						 =>   @object.customer.name  ,
                          	:customer_id					 =>   @object.customer.id   ,
                          	:user_id             =>   @object.user.id , 
                          	:user_name 										 =>   @object.user.name,
                          	:complaint_date 										 =>   format_date_friendly(@object.complaint_date)    ,
                          	:complaint 							 =>   @object.complaint ,
                          	:complaint_case 									 =>    @object.complaint_case ,
                          	:complaint_case_text 											 =>   @object.complaint_case_text,
                          	:diagnosis_date 											 =>   format_date_friendly( @object.diagnosis_date )   ,
                          	:diagnosis =>   @object.diagnosis     ,
                            :diagnosis_case =>   @object.diagnosis_case,                            # 
                            :diagnosis_case_text                               => @object.diagnosis_case_text,
                            :is_diagnosed   => @object.is_diagnosed,
                            :solution_date                           =>  format_date_friendly( @object.solution_date ),
                            :solution      => @object.solution ,
                          	:solution_case => @object.solution_case,
                          	:solution_case_text => @object.solution_case_text,
                          	:is_solved => @object.is_solved,
                          	:is_confirmed => @object.is_confirmed,
                            :is_deleted => @object.is_deleted
                          ],
                        :total => Maintenance.active_objects.count  } 
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
    @object = Maintenance.find(params[:id])
    @object.delete_object

    if @object.is_deleted and @object.errors.size == 0
      render :json => { :success => true, :total => Maintenance.active_objects.count }  
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
  
    else
      @objects = Maintenance.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Maintenance.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
