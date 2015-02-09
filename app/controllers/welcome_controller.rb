class WelcomeController < ApplicationController
  before_filter :require_login, :except => ["activate_user"]
  before_filter :require_activation, :except => ["activate_user","send_mail"]
  before_filter :require_client_restrict, :except => ["send_mail", "activate_user"]

  def help
    
  end
  
  
  
  def index
    today = Date.today
    @todayRecs = TimeTable.where(:date => today,:user_id => session[:user_id])    
    @user = User.find(session[:user_id])
    @aps = @user.assigned_projects
	@managedProjects = @user.project_managers
	@locked = @user.locked
   @todayRecsProjectDatas = []

    @weekRecs = TimeTable.where(:date => today.beginning_of_week..today.end_of_week, :user_id => @user.id).group_by(&:project_data_id)
   @selectArray = []
   if !@aps.nil?
	   	@aps.each do |a|
			pid = a.project_data_id.to_i
			if !a.project_data.nil?
   				if a.project_data.active && !a.project_data.locked
     				@selectArray << [a.project_data.name, pid]
     			end
     		end
   		end
   	end	

	if !@weekRecs.blank?
	@weekRecs.each do |key, value|
		pid = key.to_i
   		@todayRecsProjectDatas << pid
   	if AssignedProject.where(:project_data_id => pid, :user_id => @user.id).blank? && !is_archived(pid)
   		project = ProjectData.find(pid)
   		if project.active && !project.locked
			@selectArray << [project.name, pid]
   		end
   	end
   end	
	end
   
   if !@managedProjects.blank?
   	@managedProjects.each do |m|
   		pid = m.project_data_id.to_i
   		if !is_archived(pid)
   			project = m.project_data
			if !project.blank?
   				if project.active && !project.locked
   					@selectArray << [project.name,  project.id.to_i]
   			end	end
   		end
   	end
   end
    
    #Get projects that are currently archived
    
    @selectArray.sort_by! {|a| a[0].downcase}
	@selectArray.unshift(["Please Select", ""])
	
  end

def loadToDay
   today = Date.strptime(params[:toDay], '%m/%d/%Y')
    @user = User.find(session[:user_id])
   @todayRecs = TimeTable.where(:date => today, :user_id => @user.id)
   @weekRecs = TimeTable.where(:date => today.beginning_of_week..today.end_of_week, :user_id => @user.id).group_by(&:project_data_id)
   @todayRecsProjectDatas = []
   @aps = @user.assigned_projects
   	@managedProjects = @user.project_managers

   @locked = @user.locked
   if today < today.beginning_of_month && @user.prev_month_locked
   		@prev_month_locked = true
   else
   		@prev_month_locked = false
   	end
   	
   @selectArray = []
   if !@aps.nil?
	   	@aps.each do |a|
			pid = a.project_data_id.to_i
			if !a.project_data.nil?
   				if a.project_data.active && !a.project_data.locked
     				@selectArray << [a.project_data.name, pid]
     			end
     		end
   		end
   	end	

	if !@weekRecs.blank?
	@weekRecs.each do |key, value|
		pid = key.to_i
   		@todayRecsProjectDatas << pid
   	if AssignedProject.where(:project_data_id => pid, :user_id => @user.id).blank? && !is_archived(pid)
   		project = ProjectData.find(pid)
   		if project.active && !project.locked
			@selectArray << [project.name, pid]
   		end
   	end
   end	
	end
   if !@managedProjects.blank?
   	@managedProjects.each do |m|
   		project = m.project_data
   		if !project.blank?
   			if project.active && !project.locked
   				@selectArray << [project.name,  project.id.to_i]
   			end
   		end
   	end
   end
	
   @selectArray.sort_by! {|a| a[0].downcase}
	@selectArray.unshift(["Please Select", ""])


 	
   render :html => "loadToDay", :layout => false
 end
  
  
  def check_TS_locks
	  ts_locks = {}
  	user = User.find(session[:user_id])
	  ts_locks['prev_month'] = user.prev_month_locked
	  ts_locks['user'] = user.locked
	  render :json => ts_locks.to_json
  end
  
  def approve_report    
    @sr = SubmittedReport.find(params[:rid])
    @sr.approved = true
    @sr.save
    WelcomeMailer.report_approval(@sr).deliver
    flash.notice = "Approved Successfully"
    redirect_to :controller => "admin", :action => "manageReports"
  end

 
  def reject_report
    @message = params[:comment]
    @sr = SubmittedReport.find(params[:rid])
    @sr.rejected = true
    @sr.approved = false
    @sr.feedback = @message
    @sr.save
    @u = User.find(@sr.report_for)
    WelcomeMailer.report_rejection(@sr,@message).deliver    
   #	render :text =>  "You have rejected the report of "+ @u.first_name.to_s + " " + @u.last_name.to_s
 	flash[:notice] = "You have rejected the report of "+ @u.first_name.to_s + " " + @u.last_name.to_s
   render :js => "window.location = '/manageReports'"
   # redirect_to :controller => "admin", :action => "manageReports"
  end
  
  def time_sheet_reports
    @month = Date::MONTHNAMES[Date.today.last_month.month]
    @srs = SubmittedReport.where(:approved => true, :month => @month)  
  end
  
  def view_report
    @tm = Date.today.strftime("%B %Y")    
    @first_day_of_month = Date.today.last_month.beginning_of_month
    @last_day_of_month = Date.today.last_month.end_of_month
    @monthdays = []
    @days = []
    @total_hours = 0
    @sr = SubmittedReport.find(params[:rid])    
    @user = User.find(@sr.report_for)
    (@first_day_of_month..@last_day_of_month).each { |d| 
      @days << d.strftime("%-d %B %Y || %m/%d/%Y")
      data = {}
      day = d.strftime("%Y-%m-%d")
      logger.info(day)
      todayRecs = TimeTable.where(:date => d,:user_id => @user.id )      
      todayRecs.each do |td|
        td.date = d
        k = td
        k.date = d
        @monthdays << k        
        @total_hours += td.hours.to_f
      end
      if todayRecs.length == 0
        tn = Hash.new
        tn.date = day
        tn.hours = 0
        tn.project_data_id = 0
        @monthdays << tn
      end
    }  
    @manager = User.find(session[:user_id])
    @manager_name = @manager.first_name.to_s + ' ' + @manager.last_name.to_s
    @user_name = @user.first_name.to_s + ' ' + @user.last_name.to_s
    render :html => "view_report", :layout => false
  end
  
  def activate_user
    @user = User.find_by_token(params[:token])
    @user.confirmed = "t"
    @user.save
    reset_session #this forces user to login again
    if @user.client
    	redirect_to '/Client?active=true', :notice => "You account has been successfully activated."
    else
    	redirect_to '/', :notice => "Your Account has been Activated  successfully"
 	  end
  end
  
  def send_mail
      @user = User.find(session[:user_id])
      @url = request.base_url + "/activate_user?token="+@user.token
      WelcomeMailer.registration_confirmation(@user,@url).deliver  
      render :text => "Thanks for registering with us.\n Activation mail has been sent successfully to " + @user.email + ". Please activate your account. <br/><button id='data' class='btn btn-primary' value='activate' onclick='window.location.href=\"/send_mail\"'> click here  </button> to resend activation mail"
  end

  def send_mail_client
      @user = User.find(session[:user_id])
      @url = request.base_url + "/activate_user?token="+@user.token
      WelcomeMailer.client_registration_confirmation(@user,@url).deliver  
        render :text => "Thanks for registering with us.\n Activation mail has been sent successfully to " + @user.email + ". Please activate your account. <br/><button id='data' class='btn btn-primary' value='activate' onclick='window.location.href=\"/send_mail\"'> click here  </button> to resend activation mail"
   end
  
  def verify_report
    @tm = Date.today.strftime("%B %Y")    
    @first_day_of_month = Date.today.last_month.beginning_of_month
    @last_day_of_month = Date.today.last_month.end_of_month
    @monthdays = []
    @days = []
    @total_hours = 0
    @sr = SubmittedReport.find(params[:rid])    
    @user = User.find(@sr.report_for)
    (@first_day_of_month..@last_day_of_month).each { |d| 
      @days << d.strftime("%-d %B %Y || %m/%d/%Y")
      data = {}
      day = d.strftime("%Y-%m-%d")
      logger.info(day)
      todayRecs = TimeTable.where(:date => d,:user_id => @user.id )      
      todayRecs.each do |td|
        td.date = d
        k = td
        k.date = d
        @monthdays << k        
        @total_hours += td.hours.to_f
      end
      if todayRecs.length == 0
        tn = Hash.new
        tn.date = day
        tn.hours = 0
        tn.project_data_id = 0
        @monthdays << tn
      end
    }  
    @sr.visited = true
    @sr.save
    @manager = User.find(session[:user_id])
    @manager_name = @manager.first_name.to_s + ' ' + @manager.last_name.to_s
    @user_name = @user.first_name.to_s + ' ' + @user.last_name.to_s
  end
  
  def submit_report
  	@user = User.find(session[:user_id])
    ### Pull in submitted report (if exists)
    @monthlyReport = SubmittedReport.where(:report_for => session[:user_id], :month => Date::MONTHNAMES[Date.today.last_month.month])
    @monthlyReport = @monthlyReport[0]	
   ##in case the manager is no longer in the system
    if !@user.reporter.blank?
    	@manager = User.find(@user.reporter)
    end
	if !@monthlyReport.nil?
		submitted = true
		@feedback = @monthlyReport.feedback
		@rejected = @monthlyReport.rejected
		if @rejected
				msg = "Your submitted report was rejected."
			(!@feedback.blank?) ? msg += " Please read the feedback and make any necessary changes.": msg += ""
			(!@manager.nil?) ? msg += " Email " + @manager.email + " with any questions or concerns." : msg += ""
			flash.now[:error] = msg
		end
	end
    @tm = Date.today.strftime("%B %Y")    
    @first_day_of_month = Date.today.last_month.beginning_of_month
    @last_day_of_month = Date.today.last_month.end_of_month
    @monthdays = []
    @days = []
    @total_hours = 0
    (@first_day_of_month..@last_day_of_month).each { |d| 
      @days << d.strftime("%-d %B %Y || %m/%d/%Y")
      data = {}
      day = d.strftime("%Y-%m-%d")
      todayRecs = TimeTable.where(:date => d,:user_id => session[:user_id])      
      todayRecs.each do |td|
        td.date = d
        k = td
        k.date = d
        @monthdays << k
        #@monthdays.date = d
        @total_hours += td.hours.to_f
      end
      if todayRecs.length == 0
        tn = Hash.new
        tn.date = day
        tn.hours = 0
        tn.project_data_id = 0
        @monthdays << tn
      end
    }   
    puts 'check monthdays'
    puts @monthdays
    @totalRecs = TimeTable.where(@user.id)    
    ###### All of the variables needed for signature, report validation
    	if submitted
     		if !@monthlyReport.submitted_to.nil?
     			@manager = User.find(@monthlyReport.submitted_to)
     			@manager_name = @manager.first_name + ' ' + @manager.last_name
     		else
     			redirect_to '/', :notice => "You have not been assigned a manager. Please wait to submit report."
     		end
     	end
  end
  
  def send_report
     @user = User.find(session[:user_id])
#     @user.updated = true
#     @user.save
    @cmonth = Date::MONTHNAMES[Date.today.last_month.month]
    @sr = SubmittedReport.where(:month => @cmonth, :report_for => @user.id)
    if @sr.blank?
	  @sr_new = SubmittedReport.new
	  @sr_new.report_for = @user.id
	  @sr_new.month = @cmonth 
	  @sr_new.submitted_to = @user.reporter
	  @sr_new.save
	  flash[:notice] = "Submited the report successfully."
	  redirect_to :controller => "welcome",:action => "index"
    else
    	#Reset state of report
    	@sr = @sr.first
    	@sr.rejected = false
    	@sr.feedback = ""    
    	@sr.save
      	flash[:notice] = "Submited the report successfully."
      	redirect_to :controller => "welcome",:action => "index"
	end
#     @reporting_user = User.find(@user.reporter)
#     @reporting_user.updated = true
#     @reporting_user.save
    
  end
  
  def saveDayTime
    if params[:today]
      if params[:id].nil? || params[:id].empty?
        time = TimeTable.new
      else
        time = TimeTable.find(params[:id])
      end
      today = Date.strptime(params[:today], '%m/%d/%Y')
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = today
      time.hours = params[:hours]
      time.save
    end
    data = {}
    data[:id] = time.id
    data[:msg] = "saved Successfully"
    render :json => data.to_json
  end

  def saveTime
    if params[:hiddenMonday]
      day = Date.strptime(params[:hiddenMonday], '%m/%d/%Y') 
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:monday]
      time.save
    end
    if params[:hiddenTuesday]
      day = Date.strptime(params[:hiddenTuesday], '%m/%d/%Y')	
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:tuesday]
      time.save
    end
    if params[:wednesdayHidden]
      day = Date.strptime(params[:wednesdayHidden], '%m/%d/%Y')
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:wednesday]
      time.save
    end
    if params[:thursdayHidden]
      day = Date.strptime(params[:thursdayHidden], '%m/%d/%Y')
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:thursday]
      time.save
    end
    if params[:fridayHidden]
      day = Date.strptime(params[:fridayHidden], '%m/%d/%Y')
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:friday]
      time.save
    end
    if params[:saturdayHidden]
      day = Date.strptime(params[:saturdayHidden], '%m/%d/%Y')
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:saturday]
      time.save
    end
    if params[:sundayHidden]
      day = Date.strptime(params[:sundayHidden], '%m/%d/%Y')
      time = TimeTable.new
      time.user_id = session[:user_id]
      time.project_data_id = params[:project]
      time.date = day
      time.hours = params[:sunday]
      time.save
    end
    render :text => "saved successfully"
  end

 

  def deleteDayTimesheets    
    @rec = TimeTable.where(:id => params[:id],:user_id => session[:user_id] )
    data = {}    
    if @rec[0].destroy
      data[:deleted] = true
      data[:msg] = "deleted successfully"
    else
      data[:deleted] = false
      data[:msg] = "Unable to delete the timesheet. Please try again."
    end
    render :json => data.to_json
  end

	def createPieChart
		   puts "********************************PIE CHART******************************"
   		   puts params.inspect
		   pieHash = {}        
		   today = Date.strptime(params[:today], '%m/%d/%Y')
		   puts today
    	@pieRow = TimeTable.where(:date => today,:user_id => session[:user_id] )
		unless @pieRow.nil?
			@pieRow.each do |t|
				pid = t.project_data_id.to_i
				if is_archived(pid)
					project = ArchievedProject.where(:project_data_id => pid).first
				else
					project = ProjectData.find(pid)
				end
				if pieHash.has_key?(project.name)
					i = pieHash[project.name]
					pieHash[project.name] = i + t.hours
				else
					pieHash[project.name] = t.hours
				end
			end
		end
		
			sortedKeys = pieHash.keys.sort
			newPieHash = {}
			sortedKeys.each do |name|
				newPieHash[name] = pieHash[name]
			end
			puts newPieHash
			render :json => newPieHash.to_json
		end
		
	def checkPrevTimeSheets
		puts "********************************PREV TIME SHEET CHECK******************************"
		puts params.inspect
		data = {}
		emptyDays = []
		user_id = session[:user_id]
		user = User.find(user_id)
		if !new_employee(user_id) 
			today = Date.today
    		timeTables = user.time_tables.where(:date => today.beginning_of_month..today).group_by(&:date);
			pastDate = today - 1
			emptyDay = false
			while pastDate > today.beginning_of_month
				#If day is Saturday or Sunday skip to Friday
				pastDate = (pastDate.wday == 6) ? pastDate - 1 : (pastDate.wday == 0) ? pastDate - 2 : pastDate
				if pastDate > today.beginning_of_month
					if !timeTables.has_key?(pastDate)
						emptyDays << standJTime(pastDate) 
					end
				end
				pastDate = pastDate - 1
			end
			if (emptyDays.length > 0) 
				data[:empty] = true
				data[:emptyDays] = emptyDays
				render :json => data.to_json
			else
				data[:empty] = false
				render :json => data.to_json
			end
		else
			data[:empty] = false
				render :json => data.to_json

		end
	end
	
	
	def check_prev_week_hours
		puts "********************************PREV TIME SHEET CHECK******************************"
		puts params.inspect
		data = {}
		required_weeks = []
		user_id = session[:user_id]
		user = User.find(user_id)
		
		if user.role == 'GA'
			hours_required = 20
		else
			hours_required = 40
		end
		
		if !new_employee(user_id) 
			today = Date.today.beginning_of_week
			
			startDate = today.beginning_of_month.beginning_of_week
			if startDate.month != today.month
				startDate = startDate + 7.days
			end
			
			while startDate < today
				endDate = startDate.end_of_week
    			timeTables = user.time_tables.where(:date => startDate..endDate)
				hour_total = timeTables.getTotal
				if hour_total < hours_required
					hours_needed = hours_required - hour_total
					required_weeks << [standJTime(startDate), hours_needed]
				end
				startDate = startDate + 7.days
			end  
			
			if (required_weeks.length > 0) 
				data[:lock] = true
				data[:hours_required] = hours_required
				data[:required_weeks] = required_weeks
				render :json => data.to_json
			else
				data[:lock] = false
				render :json => data.to_json
			end
		else
			data[:lock] = false
				render :json => data.to_json
		end
	end

def weekly_time_view
#dates for each week day
#label selected date
#jquery click day, remove selected class
#need hash with project names: hours clocked
#need total hours, total daily

	@project_colors = session[:project_colors]
   	@user = User.find(session[:user_id])   		   
	today = params[:today].to_date		
	@selected_date = params[:selectedDate].to_date
	userTable = @user.time_tables
	@dateSections = {}
    @weeklyTotal = 0
    startDate = (today.beginning_of_week(start_day = :monday)).to_s
    endDate = (today.end_of_week(start_day = :monday)).to_s
	if @user.role == 'GA'
		@requiredHours = 20
	else
		@requiredHours = 40
	end
	startDate.to_date.upto(endDate.to_date) do |date|
	 todaysProjects = userTable.where(:date => date)
	 timeInfo = {}
	 dayTotal = 0
	 todaysProjects.each do |t|
	 	key = t.project_data_id.to_i
	 	if is_archived(key)
	 		project = ArchievedProject.where(:project_data_id => key).first
		else
			project = ProjectData.find(key)
		end
		timeInfo[project.name] = {:hours => t.hours, :id => key}
		dayTotal = dayTotal + t.hours
	 end
	 @weeklyTotal = @weeklyTotal + dayTotal
	 timeInfo[:dayTotal] = dayTotal
	 timeInfo[:standJTime] = standJTime(date)
	 @dateSections[date] = timeInfo
	end
	render :html => 'weekly_time_view', :layout => false
		
end	

def report
	@permissions = session[:permissions]
	@roleAllows = session[:roleAllows]
	@user = User.find(session[:user_id])
	@viewable_users =[];
	if @user.manager || @user.admin || @user.time_sheet_manager
		if @user.manager
			@viewable_users = @user.reporting_gas	
			@viewable_users.sort! { |a,b| a.last_name.downcase <=> b.last_name.downcase }
		else
			@viewable_users = User.all.alpha - [@user]
		end
	elsif @user.time_sheet_collaborator
		@viewable_users = User.alpha.gas
	end		
end



end	

class Hash
  attr_accessor :date,:hours,:project_data_id
end

