class SessionsController < ApplicationController
	auto_session_timeout_actions
def project_colors
		puts 'project latest colors----------------------------------'
		colors = ['#445555', '#889999', '#4499DD','#AACCCC',
		'#517281', '#7895A2', '#AFC1CC']  
		projectColor = {}
		user = User.find(session[:user_id])
		ap = user.assigned_projects
		all_records = TimeTable.where(:user_id => user.id).group_by(&:project_data_id)
		
		projects = ap.alpha.group_by(&:project_data_id)
		archivedProjects = ap.alphaArchived.group_by(&:project_data_id)
		#already_recorded = user.project_datas.group_by(&:id)
		managed_projects = user.project_managers.group_by(&:project_data_id)
		count = 0
		stop = colors.length
		
		puts 'past projects, not archived'
		ProjectData.all.each do |project_data|
			projectColor[project_data.name] = colors[count]
				if count < (stop - 1)
			 		count += 1
				else
					count = 0
				end
		end
		ArchievedProject.all.each do |archived_project|
			projectColor[archived_project.name] = '#FF8300' 
		end

		session[:project_colors] = projectColor
	end
	
def user_allowances
	puts '=------------USERALLOWANCES----'
	permissions = {}
	roleAllows = {}
	user = User.find(session[:user_id])
	user_roles = user.user_custom_roles
	prevRank = 0
	if !user_roles.nil?
		user_roles.each do |role|
			cr = role.custom_role
			newRank = cr.ranking
			dbPermissions = role.custom_role.user_permission	
  			dbPermissions.attributes.each_pair do |name, value|
  				if name != 'id' && name != 'custom_role_id'
  					if !permissions[name].nil?
  						if permissions[name] == false && value == true
  							permissions[name] = value 
  						end
  					else
  						permissions[name] = value
  					end		
  				end

  			end
  			if newRank >= prevRank 
  				prevRank = newRank
			end
  		end
  	end

  	
  	roleAllows[:allow_admin] = false
  	roleAllows[:admin_projects] = false
  	roleAllows[:admin_users] = false
  	roleAllows[:allow_manager_home] = false
  	

    if permissions['edit_users'] == true || permissions['add_users'] == true || 
    	permissions['remove_users'] == true || user.time_sheet_manager
    	roleAllows[:allow_admin] = true
    	roleAllows[:admin_users] = true
    end
    if permissions['create_projects'] || permissions['edit_projects'] || permissions['destroy_projects'] ||
    	permissions['activate_all_projects'] || permissions['archive_all_projects'] || permissions['assign_users_all_projects'] ||
    	user.time_sheet_manager
    		roleAllows[:allow_admin] = true
    		roleAllows[:admin_projects] = true
    end 
	if permissions['assign_users_managed_projects'] || permissions['activate_managed_projects'] || permissions['archive_managed_projects']
		roleAllows[:allow_manager_home] = true
	end
	session[:permissions] = permissions
	session[:roleAllows] = roleAllows
end

  def new
	cookies[:count] = 0
    if session[:user_id] && User.exists?(:id => session[:user_id]) 
    	user = User.find(session[:user_id])
    	if user.client == true
      		redirect_to '/Client'
      	else
      		redirect_to welcome_index_path
    	end
    end  
    @user = User.new
    @identity = env['omniauth.identity']
  end
  
  def Client
  	puts 'here Client'
  		if session[:user_id] && User.exists?(:id => session[:user_id]) 
    		@current_user = User.find(session[:user_id])
    		if !@current_user.client.blank?
      			redirect_to '/work_orders'
    		else
    			redirect_to '/'
    		end
    	end
    @user = User.new
    @identity = env['omniauth.identity']

 end

 def disabled_user(auth_key)
 	if auth_key.nil?
 		return false
 	else
 		email = auth_key + "@louisiana.edu"
 		du = DisabledUser.where(:email => email)
 		dcu = DisabledUser.where(:email => auth_key)
 		if dcu.blank? && du.blank? 
 			return false
 		else
 			return true
 		end
 	end
  end

  def create    
  	if !disabled_user(params[:auth_key])
		if !params[:first_name].nil?
      env["omniauth.auth"]["info"]["first_name"] = params[:first_name]
    end
	if !params[:last_name].nil?
      env["omniauth.auth"]["info"]["last_name"] = params[:last_name]
    end
    if !params[:last_name].nil? || !params[:first_name].nil?
      env["omniauth.auth"]["info"]["name"] = params[:first_name] + " " + params[:last_name]
    end
	if !params[:role].nil?
      if params[:role] == 'GA'
        env["omniauth.auth"]["info"]["role"] = params[:role]
        env["omniauth.auth"]["info"]["reporter"] = params[:reporter]
      else
        env["omniauth.auth"]["info"]["role"] = params[:role]
      end
    end
    user = User.from_omniauth(env["omniauth.auth"])
	
	if !env["omniauth.auth"]["info"]["reporter"].nil?
      @reporter = Reporter.new
      @reporter.reporter_id = user.reporter
      @reporter.reported_id = user.id
      @reporter.save
    end
	user.save
	session[:user_id] = user.id
    if params[:first_name] && params[:last_name]
    	user.first_name = params[:first_name]
    	user.last_name = params[:last_name]
    	user.save
    end
    if !params[:client].blank?
    	if user.client.nil?
    		user.client = true
    	end
    else
    	if user.client.nil?
    		user.client = false
    	end
    end
    user.save

    if user.confirmed == "t"
    	user_allowances
    	project_colors
        if user.client == true
            flash[:notice] = "Logged in Successfully (" + user.name + ")"
            redirect_to '/work_orders'
        else
          flash[:notice] = "Logged in Successfully (" + user.name + ")"
          puts 'here visit'
          redirect_to '/' 
        end
	  else
      #	if user.client == true
      #  	redirect_to send_mail_client_path
     # 	else
        	redirect_to send_mail_path
     # 	end  
    end
	else
				flash[:notice] = "User has been disabled from EffortTracker "
			puts 'here visit'
			redirect_to '/' 
	end
    #	else
    #		UserMailer.registration_confirmation(user).deliver
    #		redirect_to petitions_path, notice: "A confirmation e-mail has been send to your inbox."
    #	end
  end

  def destroy
  	@current_user = User.find(session[:user_id])
    session[:user_id] = nil
    cookies.delete(:remember_token)
	cookies.delete(:count)
	cookies[:count] = 0
    if @current_user.client
    	destination = '/Client'
    else
    	destination = root_path
    end
    @current_user = nil
    puts destination
    redirect_to destination, notice: "Signed out!"
    puts session[:user_id]
  end

  def failure
		flash.now[:alert] = "Authentication failed, please try again."
      	redirect_to :back
	end
	
### For testing users
def render_role_info
	id = params[:id]
	user = User.find(id)
	ucr = user.user_custom_roles.first
	if !ucr.blank?
		cr = ucr.custom_role
		@role = cr.role_name
		@description = cr.description
	elsif user.role == 'GA'
		@role = 'GA'
		@description = "Graduate assistant. Works 20 hours a week and required to submit monthly time sheets to manager."
	else
		@role = 'Employee'
		@description = 'Tracks hours to EffortTracker.'
	end
	render :html => 'render_role_info', :layout => false
end

  #session timeout operation
  def active
   render_session_status
  end

  def timeout
    render_session_timeout
  end

end