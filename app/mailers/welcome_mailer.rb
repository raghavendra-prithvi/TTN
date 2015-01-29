class WelcomeMailer < ActionMailer::Base
  default from: "admin@louisiana.edu"
  def registration_confirmation(user,url)
  	puts 'welcome mailer'
    if user.nil?
      @user = User.find(session[:user_id])
    else
      @user = user
    end
    @url = url
    mail :to => user.email, :from => "admin_timetracker@louisiana.edu", :subject => "User Registration Confirmation Mail"   
  end
  
  def client_registration_confirmation(user,url)
    puts 'welcome mailer client'
    if user.nil?
      @user = User.find(session[:user_id])
    else
      @user = user
    end
    @url = url
    mail :to => user.email, :from => "admin_timetracker@louisiana.edu", :subject => "User Registration Confirmation Mail"   
  end
  
  def report_approval(sr)  	
    @sr = sr
    @ru = User.find(sr.report_for)
    @mu = User.find(sr.submitted_to)
    mail :to => @ru.email, :from => "admin_timetracker@louisiana.edu", :subject => "TimeSheet Approved"   
  end
  
  def password_reset(user)
    @user = user
    mail :to => @user.email, :from => "admin_timetracker@louisiana.edu", :subject => "Password Reset"   
  end
  
  def report_rejection(sr,msg)  
    @message = msg
    @sr = sr
    @ru = User.find(sr.report_for)
    @mu = User.find(sr.submitted_to)
    mail :to => @ru.email, :from => "admin_timetracker@louisiana.edu", :subject => "TimeSheet Rejected"   
  end
  
  def send_mail_from_iphone(email,message)      
    @msg = message
    mail :to => email, :from => "admin@louisiana.edu", :subject => "NetSpector"   
  end
  
def WO_request_alert(admin, work_order)
  	@admin = admin
  	@work_order = work_order
  	mail :to => @admin.email, :from => "admin_timetracker@louisiana.edu", :subject => "New Work Order Request"  
  end
  
  def WO_request_response(client, work_order, customMessage, includePMList)
  	@work_order = work_order
  	@customMessage = customMessage
  	
  	if @work_order.approved == true
  		@status = 'approved'
  	elsif @work_order.approved == false
  		@status = 'rejected'
  	elsif @work_order.nil? 
  		@status = 'on hold'
  	end
  	@client = client

  	mail :to => @client.email, :from => "admin_timetracker@louisiana.edu", :subject => "Work Order Processed"   
  end

  
  def project_manager_assignment(projectManager, work_order, customMessage)
  @work_order = work_order
  @pm = projectManager
  @customMessage = customMessage
  @assignedEmps = @work_order.project_data.assigned_projects
  @project = @work_order.project_data
  @otherManagers = @project.project_managers.where(:user_id != @pm.id)
  mail :to => @pm.email, :from => "admin_timetracker@louisiana.edu", :subject => "Assigned to Manage New Project"   
  end
  
  def employee_assignment(employee, work_order, customMessage, includeEMList)
    @work_order = work_order
	@employee = employee
	@customMessage = customMessage
	@project = @work_order.project_data
	@includeEMList = includeEMList
	if @includeEMList == true
  	@otherEmployees = @project.assigned_projects.where.not(:user_id => @employee.id)
  	@otherEmployees.each do  |o|
  	puts 'check mail user'
  	puts User.find(o.user_id).last_name
  	end
  	end
  	mail :to => @employee.email, :from => "admin_timetracker@louisiana.edu", :subject => "Assigned to New Project"   
  	
  end
end


	
