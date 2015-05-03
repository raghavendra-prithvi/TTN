class UsersController < ApplicationController
  before_filter :require_admin
  def new
  	@user = User.new
  end

  def destroy
    sign_out
    #redirect_to petitions_path
  end

  def create
  	puts 'User create'
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Thanks for Registering! An e-mail has been sent to you to confirm your account"
      redirect_to petitions_path
	  UserMailer.registration_confirmation(@user).deliver
    else
      render 'new'
    end
  end

  def edit
  	@user = User.find(params[:id])
    @status = @user.confirmed
		if @status == "false"
			session[:user_id] = @user.id
			confirm @user
			flash[:success] = "Successfully logged in!"
			redirect_to petitions_path
		end
  end

  def update
      if current_user.update_attributes(params[:user])
        flash[:success] = "Modified Account!"
        redirect_to petitions_path
      else
        flash[:success] = "NOT Modified Account!"
        redirect_to petitions_path
      end
  end

  def registered
    @user = current_user
  end
end
