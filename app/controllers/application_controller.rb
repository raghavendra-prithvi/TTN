class ApplicationController < ActionController::Base
  protect_from_forgery
  auto_session_timeout 15.minute
  include SessionsHelper
  
  #Exception Handling
#  rescue_from Exception, :with => :handle_exceptions
 #rescue_from ActionController::RoutingError, :with => :error_render_method

  def error_render_method
     render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
    true
  end

  
  
  def require_login       
    if !session[:user_id].nil? && !User.where(id: session[:user_id]).empty?
      @current_user = User.find(session[:user_id])     
    	if params[:client] == true
    	  redirect_to '/Client'
      end      
    else
    	if params[:client] == true
    		redirect_to '/Client'
    	else
      		redirect_to :root
    	end
    end
    	cookies[:count] = cookies[:count].to_i + 1
  end
    
  
  def require_admin
    if !session[:user_id].nil? 
      @current_user = User.find(session[:user_id])
      roleAllows = session[:roleAllows]
      if @current_user.admin == true || @current_user.time_sheet_manager == true  || @current_user.work_order_admin || 
      @current_user.project_admin || roleAllows[:allow_admin]
        puts "Passed admin test.....###############################################"
        return true
      else
        redirect_to :root
      end
    else
      redirect_to :root      
    end
  end

  def require_project_admin
    if !session[:user_id].nil? 
     roleAllows = session[:roleAllows]
      @current_user = User.find(session[:user_id])
      if @current_user.project_admin || roleAllows[:admin_projects]
        return true
      else
      	flash[:notice] = "User not authorized."
        redirect_to :root
      end
    else
      redirect_to :root      
    end
  end
  
  def require_activation
    if !session[:user_id].nil?
      @current_user = User.find(session[:user_id])
      if @current_user.confirmed != "t"  
        render :text => "Please activate User. <button id='data' class='btn btn-primary' value='activate' onclick='window.location.href=\"/send_mail\"'> click here  </button> to resend activation mail."
      end
    else
      redirect_to :root
    end  
  end

  def require_work_order_admin
  	if !session[:user_id].nil? && User.find(session[:user_id])
  		u = User.find(session[:user_id])
  		if u.work_order_admin
  			return true
  		else
			  flash[:notice] = "User not authorized."
  			redirect_to :root
  		end
  	end
  end

  def require_client_restrict
  	if !session[:user_id].nil?
  		u = User.find(session[:user_id])
  		if !u.client
  			return true	
  		else
  			redirect_to '/Client'
  		end
  	end
  end
  
  def require_client
  	if session[:user_id] && User.find(session[:user_id])
		u = User.find(session[:user_id])
		if u.client
			return true
		else
			redirect_to '/welcome/index'
		end
	end
  end

  
  def require_time_sheet_manager_or_manager
    u = User.find(session[:user_id])
    if u.time_sheet_manager == true || u.manager == true
      return true
    else
      return false
    end
  end
  
 	def standJTime(date)
		Time.parse(date.to_s).utc.to_i*1000
	end
	
	def new_employee(uid)
		user = User.find(uid)
		createdDate = user.created_at
		today = Date.today
		if today >= createdDate + 3.days
			return false
		else
			return true
		end
	end
	


def require_admin_user
      roleAllows = session[:roleAllows]
	if roleAllows[:admin_users]
		return true
	else
		flash[:notice] = "User not authorized."
  		redirect_to :root
	end	
end

def require_admin_project
    roleAllows = session[:roleAllows]
	if roleAllows[:admin_projects]
		return true
	else
		flash[:notice] = "User not authorized."
  		redirect_to :root
	end	
end

def require_manager
	@permissions = session[:permissions]
	user = User.find(session[:user_id])
	if user.manager || @permissions['assign_users_managed_projects'] || @permissions['activate_managed_projects'] || @permissions['archive_managed_projects']
		return true
	else
		flash[:notice] = "User not authorized"
		redirect_to :root
	end
end

def is_archived(id)
	archived = ArchievedProject.where(:project_data_id => id.to_i)
	if archived.blank?
		return false
	else
		return true
	end
end

def user_discover(id)
	disabled = DisabledUser.where(:user_id => id)
	if disabled.blank?
		return User.find(id)
	else
		return disabled.first
	end

end

  protected

  def handle_exceptions(e)
    case e
    when AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, ActionController::RoutingError
      not_found
    else
      internal_error(e)
    end
  end

  def not_found
    render :file => "#{Rails.root}/public/404.html", :layout => false, :status => 404
  end

  def internal_error(exception)
    #if Rails.env == 'production'
      #ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
    @exception = exception.message
      render :file => "#{Rails.root}/public/500.html", :layout => false, :status => 500
    #else
    #  throw exception
    #end
  end 
  
  
  
  
  ####################

  
end
