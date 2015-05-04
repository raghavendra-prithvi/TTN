class ProjectsController < ApplicationController
  before_filter :require_admin, :except => :project_page
  before_filter :require_project_admin, :except => :project_page
  before_filter :require_admin_project, :except => :project_page
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  def index
    @archive_projects = ArchievedProject.all
    @user = User.find(session[:user_id])
	@projects = ProjectData.all.sort {|a,b| a.getAcctNumber <=> b.getAcctNumber}

 	#@permissions['create_projects'] || @permissions['edit_projects'] || @permissions['destroy_projects'] ||
    @permissions = session[:permissions]
    if @permissions['activate_all_projects'] || @permissions['archive_all_projects'] || @permissions['assign_users_all_projects']
		@tableViewOnly = false
	else
		@tableViewOnly = true
	end
	  	  if @user.time_sheet_manager
  	  	@time_sheet_lock = true
  	  else
  	  	@time_sheet_lock = false
  	  end
  end



  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        render :pdf => "2", :save_to_file => Rails.root.join('pdfs', "#{@project.name}.pdf")
      end
    end
  end

  # GET /projects/new
  def new
	@user = User.find(session[:user_id])
    @project= ProjectData.new

 	@managers = User.where(:manager => true).alpha
 	@employees = User.where(:role => 'Classified').alpha
 	@employees += User.where(:role => 'Unclassified').alpha
 #	@employees = @employees - @managers
 	@gas = User.where(:role => 'GA').alpha

	@internalAcct = {};
	InternalProjectAcctNumber.all.each do |i|
		@internalAcct[i.id] = i.acct_number
	end
  end

  # GET /projects/1/edit
  def edit
  	puts 'check edit params'
  	puts params
  	@permissions = session[:permissions]
  	@roleAllows = session[:roleAllows]
  	@wo = false
  	@project = ProjectData.find(params[:id])
  	if @project.project_type == 'wo'
  		@wo = true
  	end
 	@projectManagers = []
  	if !@project.project_managers.blank?
  		@project.project_managers.each do |pm|
  			@projectManagers << pm.user_id
  		end
 	end
 	@projectEmployees = []
 	@projectGas = []
   	if !@project.assigned_projects.blank?
  		@project.assigned_projects.each do |ap|
    		if User.exists?(:id => ap.user_id)
    			user = User.find(ap.user_id)
    			if user.role != 'GA'
			  		@projectEmployees << ap.user_id
  				else
  					@projectGas << ap.user_id
  				end
  			end
  		end
 	end


 	@managers = User.where(:manager => true).alpha
 	@employees = User.where(:role => 'Classified').alpha
 	@employees += User.where(:role => 'Unclassified').alpha
 #	@employees = @employees - @managers
 	@gas = User.where(:role => 'GA').alpha



	@user = User.find(session[:user_id])

	if @user.project_admin
		@allow = true
	else
		@allow = false
	end

	@acct_number = @project.getAcctNumber

	if !@project.project.nil?
		@internal = false
	elsif !@project.internal_project_acct_number.nil?
		@internal = true
	end

	@internalAcct = {};
	InternalProjectAcctNumber.all.each do |i|
		@internalAcct[i.id] = i.acct_number
	end


  end

   def reload_assigned_users
 	@project = ProjectData.find(params[:id])

 	@projectManagers = []
  	if !@project.project_managers.blank?
  		@project.project_managers.each do |pm|
  			@projectManagers << pm.user_id
  		end
 	end

 	@projectEmployees = []
 	@projectGas = []
   	if !@project.assigned_projects.blank?
  		@project.assigned_projects.each do |ap|
    		if User.exists?(:id => ap.user_id)
    			user = User.find(ap.user_id)
    			if user.role != 'GA'
			  		@projectEmployees << ap.user_id
  				else
  					@projectGas << ap.user_id
  				end
  			end
  		end
 	end


 	@managers = User.where(:manager => true).alpha
 	@employees = User.where(:role => 'Classified').alpha
 	@employees += User.where(:role => 'Unclassified').alpha
 #	@employees = @employees - @managers
 	@gas = User.where(:role => 'GA').alpha



	@user = User.find(session[:user_id])
	render :html => "reload_assigned_users", :layout => false
 	end



  def activate
    @project = ProjectData.find(params[:id])
    @project.active = true
    @project.save
    render :text => "success"
  end

  def deactivate
    @project = ProjectData.find(params[:id])
    @project.active = false
    @project.save
    render :text => "success"
  end

  # POST /projects
  def create
    if project_params[:name].nil?
      render :text => project_params.to_s
    end
    @project = ProjectData.new(params[:project])
    if @project.save!
      redirect_to projects_path, notice: 'Project was successfully created.'
    else
      render action: 'new'
    end
  end
# PATCH/PUT /projects/1
  def update
    puts params
    @project=ProjectData.find(params[:id])
    @project.name = params[:project][:name]
    @project.type = params[:project][:type]
    @project.project_id = params[:project][:acct_number]
	if !params[:project][:project_managers_attributes].nil?
		@project_managers = @project.project_managers
		@project_managers.each do |p|
			p.destroy
		end
		buildCount = params[:project][:project_managers_attributes].length
		count = 0
  		for i in 0..(buildCount-1)
			@project_manager = @project.project_managers.build
			@project_manager.user_id = params[:project][:project_managers_attributes][count.to_s]['user_id']
			@project_manager.save
			count += 1
		end
  	end
    if @project.save
      redirect_to projects_path, notice: 'Project was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /projects/1
  def archive_project
  	@project = ProjectData.find(params[:pid])
  	if @project.locked
   	 	@archive_project = ArchievedProject.new
    	@archive_project.name = @project.name
    	@archive_project.project_data_id = @project.id
    	if !@project.project_managers[0].nil?
      		@archive_project.user_id = @project.project_managers[0].user_id
    	end
     	if !@project.project.nil?
      		@archive_project.acct_number = @project.project.acct_number
    	end
    	@archive_project.save
    	@project.destroy
    	redirect_to projects_url, notice: 'Project was successfully archived.'
    else
    	data = {}
    	data[:fail] = true
    	data[:msg] = "Project needs to be locked by Time Sheet Manager before Archiving."
    	render :json => data
    end
  end

  def create_report
    @user = User.find(session[:user_id])
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        render :pdf => "#{@user.name}",
        :save_to_file => Rails.root.join('pdfs', "#{@user.name}.pdf")
      end
    end
  end

  def assign
    @usr = User.find(params[:id])
    @projects = ProjectData.where(:active => true)
  end

  def archived
    @aps = ArchievedProject.all
  end

  def archivedProjectDetails
    @p = ArchievedProject.find(params[:projectId])
    @assi_prj = AssignedProject.where(:project_data_id => @p.project_data_id)
    @proj_man = ProjectManager.where(:project_data_id => @p.project_data_id)
    @tt = TimeTable.where(:project_data_id => @p.project_data_id)
    @hrs = 0
    @tt.each do |t|
      @hrs += t.hours
    end
    render :html => "archivedProjectDetails", :layout => false
  end

  def save_project
      managers = params[:managers]
      employees = params[:employees]
      gas = params[:gas]
  	  descript = params[:descript]
      project = ProjectData.find(params[:project_data_id])
      if project.project_type != 'wo'
        project.project_type = 'internal'
      end
      if !params[:name].blank?
        project.name = params[:name]
      end
    if project.valid?
          pm = project.project_managers
          if !pm.blank?
              pm.each do |pmx|
                pmx.destroy
              end
          end
          ap = project.assigned_projects
          if !ap.blank?
            ap.each do |apx|
              apx.destroy
            end
          end
          if !managers.blank?
            managers.each do |m|
              pm = project.project_managers.build
              pm.user_id = m
              pm.save
            end
          end
          puts 'check employees'
          puts employees
          if !employees.blank?
            employees.each do |e|
              ap = project.assigned_projects.build
              ap.user_id = e
              ap.save
            end
          end
          if !gas.blank?
              gas.each do |g|
                ap = project.assigned_projects.build
                ap.user_id = g
                ap.save
              end
          end
          project.description = descript
          if params[:acct] != ''
              puts 'made it here'
              if (params[:internal] == 'false') && (params[:new] == 'false')
                  pid = params[:acct]
                  project.project_id = pid
                  project.save
              elsif (params[:new] == 'true')
                  project.save
                  i = InternalProjectAcctNumber.new
                  i.project_data_id = project.id
                  i.acct_number = params[:acct]
                  i.save
              elsif (params[:internal] == 'true') && (params[:new] == 'false')
                  project.save
                  i = InternalProjectAcctNumber.find(params[:acct])
                  if i.project_data_id != project.id
                    i2 = InternalProjectAcctNumber.new
                    i2.project_data_id = project.id
                    i2.acct_number = i.acct_number
                    i2.save
                  end
              end
          else
            project.save
          end
          render :text=> 'success'
      else
          render :text => project.errors.full_messages
      end
 	 end


  def create_project
    managers = params[:managers]
    employees = params[:employees]
    gas = params[:gas]
    descript = params[:descript]
    project = ProjectData.new
    if !params[:type].blank?
      project.project_type = params[:type]
    end
	  if !params[:name].blank?
      project.name = params[:name]
    end
    if project.valid?
          if !managers.blank?
            managers.each do |m|
              pm = project.project_managers.build
              pm.user_id = m
              pm.save
            end
          end
          puts 'check employees'

          puts employees

          if !employees.blank?
            employees.each do |e|
              ap = project.assigned_projects.build
              ap.user_id = e
              ap.save
            end
          end
          if !gas.blank?
              gas.each do |g|
                ap = project.assigned_projects.build
                ap.user_id = g
                ap.save
              end
          end
          project.description = descript
          if params[:acct] != ''
            puts 'made it here'
              if (params[:internal] == 'false') && (params[:new] == 'false')
                    pid = params[:acct]
                    project.project_id = pid
                    project.save
              elsif (params[:new] == 'true')
                    project.save
                    i = InternalProjectAcctNumber.new
                    i.project_data_id = project.id
                    i.acct_number = params[:acct]
                    i.save
              elsif (params[:internal] == 'true') && (params[:new] == 'false')
                    project.save
                    i = InternalProjectAcctNumber.find(params[:acct])
                    if i.project_data_id != project.id
                        i2 = InternalProjectAcctNumber.new
                        i2.project_data_id = project_id
                        i2.acct_number = i.acct_number
                        i2.save
                    end
               end
            else
                project.save
            end
          render :text=> 'success'
      else
        render  :text => project.errors.full_messages
      end
 	 end



 	 def project_page
        roleAllows = session[:roleAllows]
        permissions = session[:permissions]
        @project_colors = session[:project_colors]
		@user = User.find(session[:user_id])
#permissions for viewing all projects
#if they have any outside permissions, give them access to other project view
		puts 'check permissions'
		puts permissions
		if permissions['edit_projects']
			@privs = true
		else
			@privs = false
		end

		if @user.role != "GA"
			@showAll = true
			@all_active_projects = TimeTable.where(:date => Date.today.beginning_of_month..Date.today.end_of_month).group_by(&:project_data_id)
		else
			@showAll = false
			@all_active_projects = []
		end
		@aps = @user.assigned_projects
		@managed_projects = @user.project_managers
		@user_active_projects = TimeTable.where(:date => Date.today.beginning_of_month..Date.today.end_of_month, :user_id => @user.id).alpha.group_by(&:project_data_id)

		@currentProjects = []
    	@archivedProjects = []
    	@managedProjects = []
    	@userActiveProjects = []
    	@allActiveProjects = []

    if !@aps.blank?
    	@aps.each do |a|
    		if !is_archived(a.project_data_id)
      	 		@currentProjects << [a.project_data.name, a.project_data.id]
   			end
  		end
  	end

    if !@managed_projects.nil?
    	@managed_projects.each do |mp|
    		if !is_archived(mp.project_data_id) && !mp.project_data.nil?
      	 		@managedProjects << [mp.project_data.name, mp.project_data.id]
   			end
  		end
  	end

    if !@user_active_projects.nil?
    	@user_active_projects.each do |key, value|
    		pid = key.to_i
    		if !is_archived(pid) && AssignedProject.where(:user_id => @user.id, :project_data_id => pid).blank?
    			project = ProjectData.find(pid)
      	 		@userActiveProjects << [project.name, pid]
   			end
  		end
  	end

    if !@all_active_projects.nil?
    	@all_active_projects.each do |key, value|
    	    pid = key.to_i
    		if !is_archived(pid)
    			project = ProjectData.find(pid)
      	 		@allActiveProjects << [project.name, pid]
   			end
  		end
  	end

	puts @currentProjects
    @currentProjects.sort_by! {|a| a[0].downcase}
    	puts @currentProjects

    @managedProjects.sort_by! {|a| a[0].downcase}
    @allActiveProjects.sort_by! {|a| a[0].downcase}
	@userActiveProjects.sort_by! {|a| a[0].downcase}
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = ProjectData.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project).permit(:name, :category,:project_id,:acct_number,:user_id)
    end

end