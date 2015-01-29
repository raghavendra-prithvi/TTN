class ProjectDataController < ApplicationController
  before_filter :require_admin
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  def index
    @projects = ProjectData.all
    @archive_projects = ArchievedProject.all
  end

  # GET /projects/1
  def show
    @project = ProjectData.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        render :pdf => "2", :save_to_file => Rails.root.join('pdfs', "#{@project.name}.pdf")
      end
    end
  end

  # GET /projects/new
  def new
    @project = ProjectData.new
    @project.project_managers.build
  end

  # GET /projects/1/edit
  def edit
  	@p = ProjectData.find(params[:id])
  	@managers = []
  	if !@p.project_managers.blank?
  		@p.project_managers.each do |pm|
  			@managers << pm.user_id
  		end
  	end

  	
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
    #@project.category = params[:project][:category]
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
      redirect_to projects_path, notice: 'ProjectData was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /projects/1
  def destroy
    @archive_project = ArchievedProject.new
    @archive_project.name = @project.name
    @archive_project.project_data_id = @project.id
    if !@project.project_managers[0].nil?
      @archive_project.user_id = @project.project_managers[0].user_id
    end
    #@archive_project.category = @project.category
    @archive_project.acct_number = Project.find(@project.project_id).acct_number
    @archive_project.save
    @project.destroy
    redirect_to projects_url, notice: 'ProjectData was successfully archived.'
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
    @assi_prj = AssignedProject.where(:project_id => @p.project_data_id)
    @tt = TimeTable.where(:project_data_id => @p.project_data_id)
    @hrs = 0
    @tt.each do |t|
      @hrs += t.hours
    end
    render :html => "archivedProjectDataDetails", :layout => false
  end
  
  def save_project
	managers = params[:managers]
  	managers = params[:managers].split(",").map(&:to_i)
	pid = params[:pid]
	
	p = ProjectData.find(pid)
	pm = p.project_managers
	if !pm.blank?
  		pm.each do |pmx|
  			pmx.destroy
  		end
  	end
  	managers.each do |m|
  		pm = p.project_managers.build
  		pm.user_id = m
  		pm.save
  	end
  	render :text=> 'success'
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = ProjectData.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project_data).permit(:name, :type, :project_id)
    end
end
