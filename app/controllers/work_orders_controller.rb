class WorkOrdersController < ApplicationController
  before_filter :require_activation, :except => ["activate_user","test_mail"]
  before_filter :require_client
  before_filter :set_WO_groups, :only => [:index, :show, :edit, :new]


  def set_WO_groups
    @client = User.find(session[:user_id])
    @work_orders = @client.work_orders
    @work_order_admin = User.where(:work_order_admin => true)
    if @work_order_admin.count > 1 
      @multiple_admin = true
    else
      @multiple_admin = false
    end
  	@saved_work_orders = @work_orders.saved
    @submitted_work_orders = @work_orders.submitted
    @approved_work_orders = @work_orders.approved
    @resubmit_work_orders = @work_orders.resubmit
    @rejected_work_orders = @work_orders.rejected
    @cancelled_work_orders = @work_orders.cancelled   
  end
  
  # GET /work_orders
  def index
  	Attachment.all.each do |a|
  		if a.work_order_id.nil?
  			a.destroy
  		end
  	end
    @work_order_admin = User.where(:work_order_admin => true)
    if @work_order_admin.count > 1
    	@multiple_admin = true
    else
    	@multiple_admin = false
		@work_order_admin = @work_order_admin[0]
	end
    
     
  end

  # GET /work_orders/1
  def show
  	puts 'check out show'
  	puts params
  	@work_order = WorkOrder.find(params[:id])
	@feedback = WorkOrderFeedback.where(:client_id => session[:user_id], :work_order_id => @work_order.id)
  end

  # GET /work_orders/new
  def new
  	puts 'Made it here'
    @work_order = WorkOrder.new
    @work_order.ull_team_members.build
    @work_order.attachments.build
    @show = true
    


  end

  # GET /work_orders/1/edit
  def edit
  	@work_order = WorkOrder.find(params[:id])
  	if @work_order.attachments.count == 0
  		@work_order.attachments.build
  	end
  	if @work_order.ull_team_members.count == 0
  		@work_order.ull_team_members.build
  	end
  	if @work_order.approved || @work_order.submitted
  		@show = false
  	else
  		@show = true
  	end
  end

  


  # POST /work_orders
  def create
  	 puts 'check here'
  	puts params
    @work_order = WorkOrder.new(params[:work_order])
    @work_order_client = WorkOrderClient.new
    @work_order_client.user_id = session[:user_id]
    if @work_order.save
    	@work_order_client.work_order_id = @work_order.id
    	@attachments = Attachment.where(:work_order_id => nil)
    	@attachments.each do |a|
    		a.work_order_id = @work_order.id
    		a.save
    	end
    	
    	
    	if @work_order_client.save
    		redirect_to @work_order, notice: 'Work order was successfully created.'
    	else
    		render action: 'new'
    	end
    else
      render action: 'new'
    end
  end
  





  # PATCH/PUT /work_orders/1
  def update
  	puts params[:work_order]
  	@work_order = WorkOrder.find(params[:id])
  	ull_tm_atts = params[:work_order][:ull_team_members_attributes]
  	ull_tm_atts.each do |key, value|
  		if value.length < 2 && !value['id'].blank?
  		  	attr = UllTeamMember.find(value['id'].to_i).destroy
  			params[:work_order][:ull_team_members_attributes] = params[:work_order][:ull_team_members_attributes].except!(key)
  		end
  	end
  	puts 'new params'
  	puts params
    if @work_order.update(params[:work_order])
      redirect_to @work_order, notice: 'Work order was successfully updated.'
    else
      render action: 'edit'
    end
  end



  def submit
  	data = {}
  	@work_order = WorkOrder.find(params[:id])
  	@work_order.submitted = true
  	@work_order.approved = false
  	if @work_order.save
  		data[:success]= true
  		admins = User.where(:work_order_admin => true)
  		admins.each do |a|
	   		WelcomeMailer.WO_request_alert(a, @work_order).deliver
		end
  		render :json => data.to_json

  	else
  		data[:success] = false
  		render :json => data.to_json
  	end  	
  end
  
  # DELETE /work_orders/1
  def destroy
  	puts params
  	puts 'check destroy'
  	work_order = WorkOrder.find(params[:id])
  	attachments = work_order.attachments
  	attachments.each do |a|
  		a.destroy
  	end
  	wo_clients = work_order.work_order_clients
  	wo_clients.each do |w|
  		w.destroy
  	end
    redirect_to work_orders_url, notice: 'Work order was successfully destroyed.'
  end
  
  def get_attachments
  	puts params
  	data= {}
  	if params[:work_order_id] != ''
  		@work_order = WorkOrder.find(params[:work_order_id])
  		@attachments = @work_order.attachments
  	else
  		@attachments = []
  	end
	render :json => @attachments.to_json
  end

	def check_attachment
		data = {}
  	if params[:work_order_id] != ''
		@work_order = WorkOrder.find(params[:work_order_id])
		@attachments = @work_order.attachments
		file_name = params[:file_name]
		new_file_name = file_name.tr(" ", "_")
		data[:already_exists] = false
		@attachments.each do |a|
			if File.basename(a.attachment.to_s) == new_file_name
				data[:already_exists] = true
				data[:url] = a.attachment_url
				data[:aid] = a.id
			end
		end
				render :json => data.to_json

	else
		render :json => data.to_json
	end
	end

	def delete_attachment
		@attachment = Attachment.find(params[:aid])
		data = {}
		if @attachment.destroy
			data[:success] = true
		end
		
		render :json => data.to_json
		
	end


  
  def work_order_tracking
  	@actualWorkOrders = []
  	@client = User.find(session[:user_id])
  	@work_orders = @client.work_orders.approved
  	@work_orders.each do |w|
  		 @actualWorkOrders << w.actual_work_order
  	end
  end
  
  
  
  def dropzone
    attachments_uploaded = []
  	length = params[:attachment].length
		response = {}
		success = false
  	for i in 0..(length-1)
  		if !params[:work_order_id].blank?
  			@work_order = WorkOrder.find(params[:work_order_id])
  	 		@attachment = @work_order.attachments.build
  	 		@attachment.attachment = params[:attachment][i.to_s]
  	 		if @attachment.save
  	 			success = true
				else
					success = false
				end
			else
  	 		@attachment = Attachment.new
  	 		@attachment.attachment = params[:attachment][i.to_s]
  	 		if @attachment.save
  	 			success = true
				else
					success = false
				end
			end
		end
		response[:success] = success
		render :json => response.to_json
 end

	

end
