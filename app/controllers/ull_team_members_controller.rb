class UllTeamMembersController < ApplicationController

  
  # GET /work_orders
  def index
    @ull_team_members = UllTeamMembers.all
  end


  # GET /work_orders/new
  def new
  	puts 'Made it here'
    @ull_team_member = UllTeamMember.new
  end

  


  # POST /work_orders
  def create
  	    puts 'check here'
  	puts params
  	puts @work_order
    @ull_team_member = UllTeamMember.new(params[:ull_team_member])
    if @ull_team_member.save
	  respond_to do |format|
	    format.json{ render :json => @ull_team_member }
	  end    
	  else
      render action: 'new'
    end
  end
  

  





  # PATCH/PUT /work_orders/1
  def update
  	@ull_team_member = UllTeamMember.find(params[:id])
    if @ull_team_member.save(params[:ull_team_member])
      redirect_to @ull_team_member, notice: 'Work order was successfully updated.'
    else
      render action: 'edit'
    end
  end



  # DELETE /work_orders/1
  def destroy
  	puts params
  	puts 'check destroy'
    UllTeamMember.find(params[:id]).destroy
    redirect_to current_page, notice: 'Work order was successfully destroyed.'
  end


end
