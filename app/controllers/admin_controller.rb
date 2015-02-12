class AdminController < ApplicationController
  before_filter :require_login
  before_filter :require_admin, :except => [:manager, :manageReports,:assignProjects,:removeProjects,:load_user_info,:hoursWorked,:searchUsers,:getUsersList]
  before_filter :require_time_sheet_manager_or_manager, :only => 'manageReports'
  before_filter :require_admin_user, :only => [:users]
  before_filter :require_manager, :only => [:manager,:assignProjects,:removeProjects,:searchUsers,:getUsersList] 
	

	def user_vars
	
	end

  def users
  	  @permissions = session[:permissions]
      @users = User.employees.alpha + User.gas.alpha
      @clients = User.where(:client=> true).alpha
      @customRoles = CustomRole.all.orderRanking
  	  @listOfRoles = ['Manager', 'Time Sheet Manager', 'Time Sheet Collaborator', 'User Admin', 'Work Order Admin', 'Project Admin']
  	  @user = User.find(session[:user_id])	
  	  @disabled_users = DisabledUser.all
	  	@selectArrayReporter = User.where(:manager => true)
  	  if @permissions['edit_users'] || @permissions['remove_users']
  	  	@viewOnly = false
  	  else
  	  	@viewOnly = true
  	  end
  	  if @user.time_sheet_manager
  	  	@time_sheet_lock = true
  	  else
  	  	@time_sheet_lock = false
  	  end
  end

#Admin Users table after Update
  def users_table
		users #calls users again to set values
    render :html => 'users_table', :layout => false
  end
  
  def projects
	    @project = ProjectData.all
  end
  
  def saveModifiedHours
    @tt = TimeModifiedReport.where(:reporting_user => params[:user].to_i,:modified_manager => session[:user_id], :project_data_id => params[:projectId].to_i, :month => params[:month], :year => params[:year] )
    if @tt.blank?
      @tt = TimeModifiedReport.new
      @tt.reporting_user = params[:user]
      @tt.modified_manager = session[:user_id]
      @tt.project_data_id = params[:projectId]
      @tt.modified_hours = params[:hours]
      @tt.month = params[:month]
      @tt.year = params[:year]
      @tt.save
    else      
      @tt[0].modified_hours = params[:hours]
      @tt[0].save
    end
    render :text => "Saved Successfully"
  end
  
  def newReportEmployee
  	year = params[:year].to_i
  	month = params[:month].to_i
  	date = Date.new(year, month)
  	startDate = date.beginning_of_month
  	@userRows = {}
  	@month = Date::MONTHNAMES[month]
  	@year = year
    @user = User.find(session[:user_id])
    @users = User.alpha
    @r_users= []
    @cmonth = Date::MONTHNAMES[date.last_month.month]

    if params[:type] == "classified"
    	@users = @users.classified
    	@titleUsers = "Classified"
    else
    	@users = @users.unclassified
		@titleUsers = "Unclassified"
	end
    
    @users.each do |c|
    	accountHash = {}
    	time_tables = c.time_tables.where(:date => startDate..startDate.end_of_month)
    	time_hash = time_tables.group_by(&:project_data_id)
    	if time_tables.blank?
    		@userRows[c] = {}
    	else
    		time_hash.each do |pid, time_records|
    			pid = pid.to_i
    			tr = TimeModifiedReport.where(:reporting_user => c.id, :modified_manager => @user.id, :project_data_id => pid, :month => startDate.month, :year => startDate.year ).first
    			if !tr.blank?
    				modifiedHours = tr.modified_hours
    			else
    				modifiedHours = 0
    			end
    			monthHours = time_tables.getProjectTotal(pid)
    			if is_archived(pid)
    				accountNumber = ArchievedProject.where(:project_data_id => pid).first.acct_number
    			else
    				accountNumber = ProjectData.find(pid).getAcctNumber
    			end
    			accountHash[accountNumber] = [monthHours, modifiedHours, pid]
    		end
    			@userRows[c] = accountHash
    		end
    	end
    render :html => "newReportEmployee", :layout => false
  end
  
  def updateUser
    @user = User.find(params[:id].to_i)
    @user.first_name = params[:first_name]
    @user.last_name = params[:last_name]
    # @user.name = params[:first_name] + ' ' + params[:last_name]
    if @user.client
    	@user.email=params[:email]    
    else
	    if(!params[:reporter].nil? && @user.reporter != params[:reporter])
  	    @user.reporter = params[:reporter]
    	  @reporting_relation = Reporter.where(:reported_id => params[:id]).first  #grab reporting relation
      	if(!@reporting_relation.nil?)
        	@reporting_relation.reporter_id = params[:reporter]
      	 	@reporting_relation.save
      else
        @new_reporting_relation = Reporter.new
        @new_reporting_relation.reported_id = params[:id]
        @new_reporting_relation.reporter_id = params[:reporter]
        @new_reporting_relation.save
      end
      if(!@user.reporter.nil? && @user.reporter != 0)
          @reporting_user = User.find(@user.reporter)
          @reporting_user.reported_by = @user.id
          @reporting_user.save
      end
    end
    @identity = Identity.where(:email => @user.email).first
    formEmail = params[:email] + '@louisiana.edu'
    if(@user.email != formEmail)
      @user.email = formEmail
      if !@identity.nil?
        @identity.email = formEmail
        @identity.save
      end
    end
    @user.role = params[:role]
    end    
    @user.save    
    render :text => "saved successfully"
  end


  
  def assign_users
    @reporting_users = Reporter.where(:reporter_id => session[:user_id])
    @r_users= []
    @reporting_users.each do |r|
      @r= User.find(r.reported_id)
      if !@r.nil?
        @r_users << @r
      end
    end
    @projects = ProjectData.all
    @assignedProjects = AssignedProject.all
    @project_users = Hash.new
        @projects.each do |p|
      @aps = AssignedProject.where(:project_data_id => p.id)
          @project_users[p.id] = @aps
      end
  end
  
  def assignProjects
    if(!params[:users].nil?)
        @users = User.find(params[:users].split(","))
        @projects = ProjectData.find(params[:projects].split(","))
        @user=User.find(session[:user_id])
        @users.each do |u|
            @projects.each do |p|
                @ap = AssignedProject.where(:user_id => u.id, :project_data_id => p.id).first
                if @ap.nil?
                    @ap_new = AssignedProject.new
                    @ap_new.user_id = u.id
                    @ap_new.project_data_id = p.id
                    @ap_new.save
                end
            end
        end
    end
    @projects = []
    ProjectData.all.each do |p|
    	p.project_managers.each do |pm|
    		if pm.user_id == @user.id
    			@projects << p
    		end
    	end
    end
    @project_users = Hash.new
    @projects.each do |p|
    	#Join with user to ignore disable user ids
        @aps = AssignedProject.where(:project_data_id => p.id).joins(:user)
        @project_users[p.id] = @aps
    end
    render :html => 'assignProjects', :layout => false
    #render :text => "saved successfully"
  end
  
  
 
  def manager
    @permissions = session[:permissions]
    @reporting_users = Reporter.where(:reporter_id => session[:user_id])
    @archive_projects_all = ArchievedProject.all
    @archive_projects = []
    @user = User.find(session[:user_id])
    @r_users = []
    @reporting_users.each do |r|
      @r = User.where(:id => r.reported_id)
      if !@r.blank?
        @r_users << @r[0]
      end
    end
    
    @projectMasterList = {}
    
    @projects = []
    ProjectData.all.each do |p|
    	p.project_managers.each do |pm|
    		if pm.user_id == @user.id
    			@projects << p
    			@projectMasterList[p.name] = p.id
    		end
    	end
    end
    
	@usersMasterList = {}
	
   @assignedProjects = AssignedProject.all
    @project_users = Hash.new
    if !@projects.blank?
    @projects.each do |p|
    	@aps = AssignedProject.where(:project_data_id => p.id)
    	if !@aps.nil? 
          @aps.each do |a|
                if !@usersMasterList[a.project_data.name].blank?
                  @usersMasterList[a.project_data.name] << [a.project_data_id, a.user_id, a.project_data.project_type]
                else
                  @usersMasterList[a.project_data.name] = []
                  @usersMasterList[a.project_data.name] << [a.project_data_id, a.user_id, a.project_data.project_type]
                end
          end
    	end
    	@project_users[p.id] = @aps
    end
    end
    
	  puts @usersMasterList
  end

  def hoursWorked
    @reporting_users = Reporter.where(:reporter_id => session[:user_id])
    @archive_projects_all = ArchievedProject.all
    @archive_projects = []
    @user = User.find(session[:user_id])
    @r_users= ['Project']
    @r_user_objs = []
    @reporting_users.each do |r|
        @r = User.where(:id => r.reported_id)
        if !@r.blank?
          @r_user_objs << @r[0]
          @r_users << @r[0].first_name
        end
    end
        
    response_data = []
    response_data << @r_users
    @projectMasterList = {}
    
    @projects = []
    ProjectData.all.each do |p|
        p.project_managers.each do |pm|
            if pm.user_id == @user.id
                @projects << p
                @projectMasterList[p.name] = p.id
            end
        end
    end
    
	@usersMasterList = {}
   
    if !@projects.blank?
          @projects.each do |p|
            new_row = []
            new_row << p.name
                @r_user_objs.each do |u|
                  @tts = TimeTable.where(:user_id => u.id, :project_data_id => p.id)
                       @hrs = 0 
                       @tts.each do |t| 
                           if( (t.date.month == Date.today.month) && (t.date.year == Date.today.year))                                   
                                 @hrs += t.hours                             
                           end 
                       end 
                      new_row << @hrs
                end
            response_data << new_row
          end
    end
    
    render :json => response_data.to_json
    
  end


  def removeProjects
  #    render :text => params[:data]
  	puts '------------- removeProjects ------------'
	@pm = User.find(session[:user_id])
     project_user_data = params[:data].split(",")
    project_user_data.each do |x|
      up = x.split("_")
      if up.length == 2
        u = up[0]
        p = up[1]
        @user = User.find(u)
        @project = ProjectData.find(p)
        @ap = AssignedProject.where(:user_id => @user.id, :project_data_id => @project.id)
        @ap.destroy_all
      end
    end
    
    @projectMasterList = {}
    
    @projects = []
    ProjectData.all.each do |p|
    	p.project_managers.each do |pm|
    		if pm.user_id == @pm.id
    			@projects << p
    			@projectMasterList[p.name] = p.id
    		end
    	end
    end
    
	@usersMasterList = {}
	
   @assignedProjects = AssignedProject.all
    @project_users = Hash.new
    if !@projects.blank?
    @projects.each do |p|
    	@aps = AssignedProject.where(:project_data_id => p.id)
    	if !@aps.nil? 
    		@aps.each do |a|
    			if !@usersMasterList[a.project_data.name].blank?
    				@usersMasterList[a.project_data.name] << [a.project_data_id, a.user_id, a.project_data.project_type]
    			else
    				@usersMasterList[a.project_data.name] = []
    				@usersMasterList[a.project_data.name] << [a.project_data_id, a.user_id, a.project_data.project_type]
    			end
    		end
    	end
    	@project_users[p.id] = @aps
    end
    end
    render :html => 'removeProjects', :layout => false
  end  
  
  def manageReports
  #going to create a json object with {clid: {acct_number: total_hours....} }
  #sort by clid, then acct_number
    @permissions = session[:permissions]
  	startDate = Date.today.beginning_of_month
  	@classifiedUserRows = {}
  	@unclassifiedUserRows = {}
  	@gaHourTable = {}
  	
    @user = User.find(session[:user_id])
    @users = User.alpha
    @r_users= []
    @sr_ga_users = []
    @cmonth = Date::MONTHNAMES[Date.today.last_month.month]
  	#collect submitted reports to current user and collect users
    @submitted_reports = SubmittedReport.where(:submitted_to => @user.id, :month => @cmonth, :approved => false, :rejected => false)
    @submitted_reports.each do |s|
      @sr_ga_users << User.find(s.report_for)      
    end
	if @user.manager
		manager_gas = @user.reporting_gas
		manager_gas.sort! { |a,b| a.last_name.downcase <=> b.last_name.downcase }
    end
    @missing_report = []
    if !manager_gas.nil?
        manager_gas.each do |m|
          ga_report = SubmittedReport.where(:submitted_to => @user.id, :month => @cmonth)
          if ga_report.blank?
            @missing_report << m
          end
        end
    end    
    
    #
    
    if @user.time_sheet_manager
    @ga_users = @users.gas
    @unc_users = @users.unclassified
    @classified_users = @users.classified
    @employee_users = @users.employees
    
    @employee_users.each do |c|
    	accountHash = {}
    	time_tables = c.time_tables.where(:date => startDate..startDate.end_of_month)
    	time_hash = time_tables.group_by(&:project_data_id)
    	if time_tables.blank?
    		if c.role == "Classified"
    			@classifiedUserRows[c] = {}
    		else
    			@unclassifiedUserRows[c] = {}
    		end
    	else
    		time_hash.each do |pid, time_records|
    			pid = pid.to_i
    			tr = TimeModifiedReport.where(:reporting_user => c.id, :modified_manager => @user.id, :project_data_id => pid, :month => Date.today.month, :year => Date.today.year )
    			if !tr.blank?
    			    tr = tr.first
    				modifiedHours = tr.modified_hours
    			else
    				modifiedHours = 0
    			end
    			monthHours = time_tables.getProjectTotal(pid)
    			if is_archived(pid)
    				accountNumber = ArchievedProject.where(:project_data_id => pid).first.acct_number
    			else
    				accountNumber = ProjectData.find(pid).getAcctNumber
    			end
    			accountHash['ts_manager_csvReport'] = [monthHours, modifiedHours, pid]
    		end
    		if c.role == "Classified"
    			@classifiedUserRows[c] = accountHash
    		else
    			@unclassifiedUserRows[c] = accountHash
    		end
    	end
    end
    end
    

    
    end



  
  # on change of month
  def monthlyEmployeeReport
  #going to create a json object with {clid: {acct_number: total_hours....} }
  #sort by clid, then acct_number
  	year = params[:year].to_i
  	month = params[:month].to_i
  	date = Date.new(year, month)
  	startDate = date.beginning_of_month
  	@classifiedUserRows = {}
  	@unclassifiedUserRows = {}
  	@gaHourTable = {}
  	
    @user = User.find(session[:user_id])
    @users = User.alpha
    @r_users= []
    @sr_ga_users = []
    @cmonth = Date::MONTHNAMES[date.month]
  	#collect submitted reports to current user and collect users
    @submitted_reports = SubmittedReport.where(:submitted_to => @user.id, :month => @cmonth, :approved => false, :rejected => false)
    @submitted_reports.each do |s|
      @sr_ga_users << User.find(s.report_for)      
    end
    
    @ga_users = @users.gas
    @unc_users = @users.unclassified
    @classified_users = @users.classified
    @employee_users = @users.employees
    
    @employee_users.each do |c|
    	accountHash = {}
    	time_tables = c.time_tables.where(:date => startDate..startDate.end_of_month)
    	time_hash = time_tables.group_by(&:project_data_id)
    	if time_tables.blank?
    		if c.role == "Classified"
    			@classifiedUserRows[c] = {}
    		else
    			@unclassifiedUserRows[c] = {}
    		end
    	else
    		time_hash.each do |pid, time_records|
    			pid = pid.to_i
    			tr = TimeModifiedReport.where(:reporting_user => c.id, :modified_manager => @user.id, :project_data_id => pid, :month => startDate.month, :year => startDate.year ).first
    			if !tr.blank?
    				modifiedHours = tr.modified_hours
    			else
    				modifiedHours = 0
    			end
    			monthHours = time_tables.getProjectTotal(pid)
    			if is_archived(pid)
    				accountNumber = ArchievedProject.where(:project_data_id => pid).first.acct_number
    			else
    				accountNumber = ProjectData.find(pid).getAcctNumber
    			end
    			accountHash[accountNumber] = [monthHours, modifiedHours, pid]
    		end
    		if c.role == "Classified"
    			@classifiedUserRows[c] = accountHash
    		else
    			@unclassifiedUserRows[c] = accountHash
    		end
    	end
    end

    render :html => "monthlyEmployeeReport", :layout => false    
  end
  

  
   ## data csv ###
  def ts_manager_csvReport    
  	year = params[:year].to_i
  	month = params[:month].to_i
  	type = params[:type]
  	date = Date.new(year, month)
  	startDate = date.beginning_of_month
  	@users = User.alpha
  	@userRows = {}
    @user = User.find(session[:user_id])
    @cmonth = Date::MONTHNAMES[date.month]
    modified = params[:modified]
  	#collect submitted reports to current user and collect users
	if type == "classified"
		@employee_users = @users.classified
	else
		@employee_users = @users.unclassified
	end
    
    @employee_users.each do |c|
    	accountHash = {}
    	time_tables = c.time_tables.where(:date => startDate..startDate.end_of_month)
    	time_hash = time_tables.group_by(&:project_data_id)
    	if time_tables.blank?
    		@userRows[c] = {}
    	else
    		time_hash.each do |pid, time_records|
    			pid = pid.to_i
    			monthHours = time_tables.getProjectTotal(pid)
    			if !modified.blank?
    				tr = TimeModifiedReport.where(:reporting_user => c.id, :modified_manager => @user.id, :project_data_id => pid, :month => startDate.month, :year => startDate.year ).first
    				if !tr.blank?
    					modifiedHours = tr.modified_hours
    				else
    					modifiedHours = 0
    				end
   				else
   					modifiedHours = monthHours
    			end
    			if is_archived(pid)
    				accountNumber = ArchievedProject.where(:project_data_id => pid).first.acct_number
    			else
    				accountNumber = ProjectData.find(pid).getAcctNumber
    			end
    			accountHash[accountNumber] = [monthHours, modifiedHours, pid]
    		end
   			@userRows[c] = accountHash    		
    	end
    end
    reporter_csv = CSV.generate do |csv|        
      csv << ["CLID", "Account Number", "Hours", "Name"]       
      @userRows.each do |u, monthHours|
		if monthHours.blank?
			csv << [u.email.split("@")[0], "", "NO TIME CLOCKED", u.name]   
		else
			monthHours.each do |acct_number, hours|
      			csv << [u.email.split("@")[0], acct_number, hours[1], u.name]   
      		end                            
        end
      end
    end
    filename = type.capitalize + "_Employees_Report.csv"
    send_data(reporter_csv, :type => 'test/csv', :filename => filename) 
  end
  
 
  
  
   def assign_project_manager
    if(!params[:user_id].nil?)
        @manager = User.find(params[:user_id])
        @project = ProjectData.find(params[:project_id])
		@ap = ProjectManagers.where(:user_id => u.id, :project_data_id => p.id)
	 	if @ap.nil?
	  		@ap_new = AssignedProject.new
	  		@ap_new.user_id = @manager.id
	  		@ap_new.project_data_id = @project.id
	  		@ap_new.save
        end
    end
    #render :json => 'assignProjects', :layout => false
    #render :text => "saved successfully"
  end
  
  def get_user_permissions
  	userInfo = {}
	userInfo[:roles] = []
  	uid = params[:uid]
  	user = User.find(uid)
  	userInfo[:name] = user.name
  	highestRanking = 0
  	if !user.user_custom_roles.blank?
  		user_map_to_roles = user.user_custom_roles
  		user_map_to_roles.each do |r|
  			role = r.custom_role
  			newRanking = role.ranking
  			userInfo[:roles] << role.id
  		end
  	end
  	puts 'check userinfo'
  	puts userInfo
  	render :json => userInfo.to_json
  end
  
  def edit_permissions
  #	forbidden = ['controller', 'user_id', 'action', 'roles']
  listOfRoles = ['manager', 'time_sheet_manager', 'time_sheet_collaborator', 'work_order_admin', 'project_admin', 'user_admin']
  	user_id = params[:user_id]
  	user = User.find(user_id.to_i)
	if params[:roles].blank?
		roleIds = []
	else
		roleIds = params[:roles]
	end
  	
  	if !roleIds.blank?
  		roleIds.each do |r|
  			cr = CustomRole.find(r.to_i)
  			userCr = UserCustomRole.where(:custom_role_id => cr.id, :user_id => user.id)
  			if userCr.blank?
  				userCr = UserCustomRole.new
  				userCr.custom_role_id = cr.id
  				userCr.user_id = user.id
  				userCr.save
  			end
  		end
  	end
  	
  	allUserCr = UserCustomRole.where(:user_id => user_id)
  	if !allUserCr.blank?
  		allUserCr.each do |acr|
  			if !roleIds.include?(acr.custom_role_id.to_s)
  				acr.destroy
  			end
  		end
	end  				
  		
  		
	roleNames = roleIds.map {|r| CustomRole.find(r).role_name.downcase.tr(" ", "_")}
	puts roleNames
	roleNames.each do |r|
		if r == 'user_admin'
			user['admin'] = true
		elsif listOfRoles.include?(r)
  			user[r] = true
  		end
  	end
	falseRoles = listOfRoles.reject{|x| roleNames.include? x}
	puts 'check false roles'
	falseRoles.each do |f|
		puts f
		if f == 'user_admin'
				user.admin = false
		else			
				user[f] = false
		end
	end
  	user.save
 	render :text => 'sucesss'
 end


  	
  	def save_new_role
  		returnMsg = {}
  		roleName = params[:role_name]
  		if !CustomRole.where(:role_name => roleName).blank?
  			returnMsg[:success] = false
  			returnMsg[:msg] = 'Role Name already used.'
  			render :json => returnMsg.to_json
  		else
  	
  		forbidden = ['controller', 'action', 'role_name', 'description', 'uid', 'ranking']
		dbPermissions = UserPermission.new
  		params.each do |permission, value|
  			if !forbidden.include?(permission)
  				dbPermissions[permission] = value
  			end
  		end
  		
  		
  		if params[:description].blank?
  			roleDescription = ''
  		else	
  			roleDescription = params[:description]
  		end
 			
 		ranking = params[:ranking]	
 		cr = CustomRole.new
  		cr.role_name = roleName
  		cr.description = roleDescription
  		cr.ranking = ranking
  		if cr.save
  		  	dbPermissions.custom_role_id = cr.id
  		  	if dbPermissions.save
  		  		returnRole = {}
  		  		returnRole[:id] = cr.id
  		  		returnRole[:name] = cr.role_name
  		  		returnRole[:description] = cr.description
  				render :json => returnRole.to_json
  			end
  		end
  	end
  	end
  
  	def delete_role
  		roleId = params[:role_id]
  		cr = CustomRole.find(roleId)
  		cr.user_permission.destroy
  		cr.user_custom_roles.destroy_all
		cr.destroy
  		render :text => 'Success'
  	end
  	
	def edit_custom_role
		puts 'THIS WAS CALLED!'
		roleId = params[:role_id]
  		cr = CustomRole.find(roleId.to_i)
  		returnMsg = {}
  		roleName = params[:role_name]
  		puts roleName
  		ranking = params[:ranking]
  		nameCheck = CustomRole.where(:role_name => roleName).first
  		if !nameCheck.nil? && nameCheck.id != roleId.to_i
  				returnMsg[:success] = false
  				returnMsg[:msg] = 'Role Name already used.'
  				render :json => returnMsg.to_json
  		else
  		forbidden = ['controller', 'action', 'role_name', 'role_id', 'description', 'uid', 'ranking', 'id']
		if !cr.user_permission.blank?
			dbPermissions = cr.user_permission
  		else
  			dbPermissions = UserPermission.new
  			dbPermissions.custom_role_id = cr.id
  		end
  		
  		puts 'check db permission for create_project'
  		puts params
  		dbPermissions.attributes.each_pair do |name, value|
  			if name != 'id' && name != 'custom_role_id'
  			puts name
  			puts value
  			puts '------'
  			if params.include?(name)
  				dbPermissions[name] = true
  			else
  				dbPermissions[name] = false
  			end
  			end
  		end
  		
  		
  		if params[:description].blank?
  			roleDescription = ''
  		else	
  			roleDescription = params[:description]
  		end
 			
  		cr.role_name = roleName
  		cr.description = roleDescription
  		cr.ranking = ranking
  		if cr.save
  		  	dbPermissions.custom_role_id = cr.id
  		  	if dbPermissions.save
  		  		puts 'made it here!'
  				returnMsg[:success] = true
				returnMsg[:msg] = 'Role Successfully saved and ready to use.'
  				render :json => returnMsg.to_json
  			end
  		end
  	end
  	end
  	
  	def get_custom_role_permissions
  	  	userInfo = {:permissions => {}}
  		rid = params[:role_id]
  		customRole = CustomRole.find(rid)
  		dbPermissions = customRole.user_permission
  			if !dbPermissions.blank?
  				dbPermissions.attributes.each_pair do |name, value|
  					if name != 'custom_role_id'
  						userInfo[:permissions][name] = value 
  					end
  				end
  			end
  	render :json => userInfo.to_json
  	end
  
  def load_custom_roles
  	  @listOfRoles = ['Manager', 'Time Sheet Manager', 'Time Sheet Collaborator', 'User Admin', 'Work Order Admin', 'Project Admin']

  	  @customRoles = CustomRole.all.orderRanking
      render :html => "custom_role", :layout => false
  end
  
  def load_new_role
  	render :html => "load_new_role", :layout => false
  end
  
  def get_role_hierarchy
  	customRoles = CustomRole.all
  	roleHierarchy = {}
  	
  	customRoles.each do |cr|
  		permissions = []
  		if !cr.user_permission.blank?
  			##roleHierarchy << {cr.role_name => {"permissons" => [], "ranking" => 0} }
  			dbPermissions = cr.user_permission
  			dbPermissions.attributes.each_pair do |name, value|
  				if name != 'custom_role_id' && value == true
  			##		roleHierarchy[-1][:permissons] << name 
  					permissions << name
  				end
  			end
  		end
  		roleHierarchy[cr.id]= {:permissions => {}, :ranking => cr.ranking}
  		roleHierarchy[cr.id][:permissions] = permissions
  	puts roleHierarchy
  end
  	render :json => roleHierarchy.to_json

 end
 
 
 
 def load_user_info
 	if params[:pid].blank?
 		@projectName = 'New Project'
 	else
 		project = ProjectData.find(params[:pid].to_i)
 		@projectName = project.name
 	end
 	@managerManagedProjects = {}
 	@managerAssignedProjects = {}
 	@employeeAssignedProjects = {}
 	@gaAssignedProjects = {}
 	@managers = User.where(:manager => true).alpha 
 	@employees = User.where(:role => 'Classified').alpha
 	@employees += User.where(:role => 'Unclassified').alpha
 	@employees = @employees - @managers
 	@gas = User.where(:role => 'GA')
 	
 	if params[:managerIds].nil?
 	 @managers = []
 	else
 	 @managers = params[:managerIds] 
 	end
 	if params[:employeeIds].nil?
 	 @employees = []
 	else
 	 @employees = params[:employeeIds] 
 	end
 	if params[:gaIds].nil?
 	 @gas = []
 	else
 	 @gas = params[:gaIds] 
 	end

 
 	
 	@managers.each do |m|
 		m = User.find(m)
 		if !m.assigned_projects.blank?
 			m.assigned_projects.alpha.each do |ap|
 				if @managerAssignedProjects[m.name].blank?
 					@managerAssignedProjects[m.name] = [ProjectData.find(ap.project_data_id).name]
 				else
 					@managerAssignedProjects[m.name] << ProjectData.find(ap.project_data_id).name
 				end
 			end
 		end
 		if !m.project_managers.blank?
 			m.project_managers.alpha.each do |pm|
 				if @managerManagedProjects[m.name].blank?
 					 @managerManagedProjects[m.name] = [ProjectData.find(pm.project_data_id).name]
 				else
 					@managerManagedProjects[m.name] << ProjectData.find(pm.project_data_id).name
 				end
 			end
 		end
 	end
 	@employees.each do |e|
 		e = User.find(e)
 		if !e.assigned_projects.blank?
  			e.assigned_projects.alpha.each do |ap|
 				if @employeeAssignedProjects[e.name].blank?
 					@employeeAssignedProjects[e.name] = [ProjectData.find(ap.project_data_id).name]
 				else
 					@employeeAssignedProjects[e.name] << ProjectData.find(ap.project_data_id).name
 				end
 		end
 		
 	end
 	end
 	
 	@gas.each do |g|
 		g = User.find(g)
 		if !g.assigned_projects.blank?
 			g.assigned_projects.alpha.each do |ap|
 				if @gaAssignedProjects[g.name].blank?
 					@gaAssignedProjects[g.name] = [ProjectData.find(ap.project_data_id).name]
 				else
 					@gaAssignedProjects[g.name] << ProjectData.find(ap.project_data_id).name
 				end
 			end
 		end
 	end
 	  	render :html => "load_new_role", :layout => false

 	
 end
 
 ##TSMANAGER LOCK FUNCTIONALITY
 	def update_user_lock
 		user_id = params[:user_id].to_i
 		user = User.find(user_id)
 		lock_status = params[:locked]
		if lock_status == 'true'
			user.locked = true
 		else
 			user.locked = false
 		end
 		user.save
 		render :text => 'success'
 	end
 	
 	def update_all_locks
 		users = User.all
 		if params[:locked] == 'true'
 			users.each do |u|
 				u.locked = true
				u.save
			end
		else
			users.each do |u|
				u.locked = false
				u.save
			end
		end
		render :text => 'Success'
	end
	
	def update_prev_month_user_lock
 		user_id = params[:user_id].to_i
 		user = User.find(user_id)
 		lock_status = params[:locked]
		if lock_status == 'true'
			user.prev_month_locked = true
 		else
 			user.prev_month_locked = false
 		end
 		user.save
 		render :text => 'success'
	
	end
	
	def update_prev_month_all_lock
		users = User.all
		lock_status = params[:locked]
		if lock_status == 'true'
			users.each do |u|
				u.prev_month_locked = true
				u.save
			end
		else
			users.each do |u|
				u.prev_month_locked = false
				u.save
			end
		end
	 		render :text => 'success'

	end
	
 	def update_project_locks
 		project_id = params[:project_id].to_i
 		project = ProjectData.find(project_id)
 		lock_status = params[:locked]
 		if lock_status == 'true'
 			project.locked = true
 		else
 			project.locked = false
 		end

 		project.save
 		render :text => 'success'
 	end
 	
 	def update_all_project_locks
 		projects = ProjectData.all
 		if params[:locked] == 'true'
 			projects.each do |p|
 				p.locked = true
				p.save
			end
		else
			projects.each do |p|
				p.locked = false
				p.save
			end
		end
		render :text => 'Success'
	end
	
	
	def disable_user
		user_id = params[:user_id].to_i
		user = User.find(user_id)
		disabled_user = DisabledUser.new
		disabled_user.user_id = user_id
		disabled_user.first_name = user.first_name
		disabled_user.last_name = user.last_name
		disabled_user.email = user.email
		disabled_user.created_at = user.created_at
		if user.client
			disabled_user.role = 'client'
		else
			disabled_user.role = user.role
		end
		##Remove Reporter Relations
		Reporter.where(:reporter_id => user.id).destroy_all
		Reporter.where(:reported_id => user.id).destroy_all
		if disabled_user.save
			user.destroy
			dataHash = {:disabled => true}
		else
			dataHash = {:disabled=> false}
		end
			render :json => dataHash.to_json
	end
	

	
	
	def enable_user
		listOfRoles = ['manager', 'time_sheet_manager', 'time_sheet_collaborator', 'work_order_admin', 'project_admin', 'user_admin']
		disabled_user_id = params[:user_id].to_i
		disabled_user = DisabledUser.find(disabled_user_id)
		user = User.new
		user.id = disabled_user.user_id
		user.first_name = disabled_user.first_name
		user.last_name = disabled_user.last_name
		user.name = disabled_user.first_name + ' ' + disabled_user.last_name
		user.role = disabled_user.role
		user.created_at = disabled_user.created_at
		user.confirmed = 't'
		if (disabled_user.role == 'client') 
			user.client = true
		end
		#Reinstate roles from permissions
		u_permissions = UserCustomRole.where(:user_id => disabled_user.user_id)
		if !u_permissions.blank?
			u_permissions.each do |up|
				cr = up.custom_role
				roleName = cr.role_name.downcase.tr(' ', '_')
				if listOfRoles.include?(roleName)
					if roleName != 'user_admin'
						user[roleName] = true
					else
						user[:admin] == true
					end
				end
			end
		end
		user.email = disabled_user.email
		if user.save
			disabled_user.destroy
			dataHash = {:enabled => true}
			render :json => dataHash.to_json
		end	
	end
	
  def searchUsers
    user = User.where("email like ?", params[:clid])
    if params[:pid].blank?
 		    @projectName = 'New Project'
 	  else
 		  project = ProjectData.find(params[:pid].to_i)
 		  @projectName = project.name
 	  end
 	@managerManagedProjects = {}
 	@managerAssignedProjects = {}
 	@employeeAssignedProjects = {}
 	@gaAssignedProjects = {}
 	@managers = User.where(:manager => true).alpha 
 	@employees = User.where(:role => 'Classified').alpha
 	@employees += User.where(:role => 'Unclassified').alpha
 	@employees = @employees - @managers
 	@gas = User.where(:role => 'GA')
 	
 	if params[:managerIds].nil?
 	 @managers = []
 	else
 	 @managers = params[:managerIds] 
 	end
 	if params[:employeeIds].nil?
 	 @employees = []
 	else
 	 @employees = params[:employeeIds] 
 	end
 	if params[:gaIds].nil?
 	 @gas = []
 	else
 	 @gas = params[:gaIds] 
 	end

 
 	
 	@managers.each do |m|
 		m = User.find(m)
 		if !m.assigned_projects.blank?
 			m.assigned_projects.alpha.each do |ap|
 				if @managerAssignedProjects[m.name].blank?
 					@managerAssignedProjects[m.name] = [ProjectData.find(ap.project_data_id).name]
 				else
 					@managerAssignedProjects[m.name] << ProjectData.find(ap.project_data_id).name
 				end
 			end
 		end
 		if !m.project_managers.blank?
 			m.project_managers.alpha.each do |pm|
 				if @managerManagedProjects[m.name].blank?
 					 @managerManagedProjects[m.name] = [ProjectData.find(pm.project_data_id).name]
 				else
 					@managerManagedProjects[m.name] << ProjectData.find(pm.project_data_id).name
 				end
 			end
 		end
 	end
 	
  e = User.where("email=?",params[:clid]).first
  if !e.assigned_projects.blank?
    e.assigned_projects.alpha.each do |ap|
      if @employeeAssignedProjects[e.name].blank?
        @employeeAssignedProjects[e.name] = [ProjectData.find(ap.project_data_id).name]
      else
        @employeeAssignedProjects[e.name] << ProjectData.find(ap.project_data_id).name
      end
    end 		
  end
 	

 	@gas.each do |g|
 		g = User.find(g)
 		if !g.assigned_projects.blank?
 			g.assigned_projects.alpha.each do |ap|
 				if @gaAssignedProjects[g.name].blank?
 					@gaAssignedProjects[g.name] = [ProjectData.find(ap.project_data_id).name]
 				else
 					@gaAssignedProjects[g.name] << ProjectData.find(ap.project_data_id).name
 				end
 			end
 		end
 	end
    
  render :html => 'searchUsers', :layout => false
  end
  
  def getUsersList
    query = '%' + params[:query] + '%'
    users = User.where("email like ?", query).pluck(:email)
    render :json => users.to_json
  end  

	def delete_user  	
    	user = User.find(params[:user_id])
    	if user.id == session[:user_id]	
    		render :text => 'failure'
		else
			reporter_relations = Reporter.where(:reported_id => user.id) #find if matched with manager when logged in
			reporter_relations.destroy_all
			user.user_custom_roles.destroy_all
    		if user.client
    			email = user.email
    			user.work_orders.destroy_all
    			user.work_order_clients.destroy_all
    		else
    			email = user.email.split("@")[0]
    		end
    		identity = Identity.where(:email => email ).first
    		if !identity.blank?
        		identity.destroy
    		end
    		user.destroy
			dataHash = {:deleted => true}
			render :json => dataHash.to_json
		end
  	end	
 ####
 
 
end
  