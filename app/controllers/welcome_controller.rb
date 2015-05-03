class WelcomeController < ApplicationController
  before_filter :require_login, :except => ["activate_user"]
  before_filter :require_activation, :except => ["activate_user","send_mail"]
  before_filter :require_client_restrict, :except => ["send_mail", "activate_user"]

  def help
    render :html => "help", :layout => false
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




end	

class Hash
  attr_accessor :date,:hours,:project_data_id
end

