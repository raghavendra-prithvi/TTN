require 'bcrypt'
class PasswordResetsController < ApplicationController
  def new
  end
  def create
      user = User.find_by_email(params[:email])
      user.send_password_reset if user
      redirect_to root_url, :notice => "Email sent with password reset instructions."
  end
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  def update
      @user = User.find_by_password_reset_token!(params[:id])      
      if @user.password_reset_sent_at < 2.hours.ago
        redirect_to new_password_reset_path, :alert => "Password &crarr; reset has expired."
      elsif params[:user]
        user_name = @user.email.split("@")[0]
        user_identity = Identity.find_by_email(user_name)
        unencrypted_password = params[:user][:password].to_s
        password_digest = BCrypt::Password.create(unencrypted_password)
        user_identity.password_digest = password_digest;
        user_identity.save!
        redirect_to root_url, :notice => "Password has been reset."
      else
        render :edit
      end
  end
  
end
