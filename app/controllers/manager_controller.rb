class ManagerController < ApplicationController
  before_filter :require_manager
  
  ###########################################################
  ######## Main Action for Manager Operations ###############
  ######## Thios is manager home ############################
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
  


  #######################################################################
  ######## Assigning Projects to User is a manager Operation ############
  #######################################################################
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
   end

  ############################################
   ###### Remove Projects to User #####################
  def removeProjects
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

  ################################################################
  ########## Manager Can Search for any User in the System ########
  #################################################################
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
end
