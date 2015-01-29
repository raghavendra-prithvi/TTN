class LoginController < ApplicationController
  def send_mail
    @email = params[:email]
    @message = params[:message]
    WelcomeMailer.send_mail_from_iphone(@email,@message).deliver
    render :text => "mail sent successfully."
  end
end
