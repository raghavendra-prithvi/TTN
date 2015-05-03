class AttachmentsController < ApplicationController

  # GET /work_orders
  def index
    @attachments = Attachment.all
  end

  # GET /work_orders/1
  def show
  	puts 'check out show'
  	puts params
  	@attachment = Attachment.find(params[:id])
  	respond_to do |format|
   format.json{ render :json => @attachment }
end

  end

  # GET /work_orders/new
  def new
  	puts 'Made it here'
    @attachment = Attachment.new
  end

  # GET /work_orders/1/edit
  def edit
  	@attachment = Attachment.find(params[:id])
  end

  


  # POST /work_orders
  def create
  	    puts 'check here'
  	puts params
  	puts @work_order
    @attachment = Attachment.new(params[:attachment])
    if @attachment.save
	  respond_to do |format|
	    format.json{ render :json => @attachment }
	  end    
	  else
      render action: 'new'
    end
  end
  

  





  # PATCH/PUT /work_orders/1
  def update
  	@attachment = Attachment.find(params[:id])
    if @attachment.save(params[:attachment])
      redirect_to @attachment, notice: 'Work order was successfully updated.'
    else
      render action: 'edit'
    end
  end



  # DELETE /work_orders/1
  def destroy
  	puts params
  	puts 'check destroy'
    Attachment.find(params[:id]).destroy
    redirect_to current_page, notice: 'Work order was successfully destroyed.'
  end


end
