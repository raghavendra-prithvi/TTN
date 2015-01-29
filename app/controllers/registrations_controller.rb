class RegistrationsController < SessionsController
	def new
	 puts 'Registration new'
	  @user = User.new
	  @user.apply_omniauth(session[:omniauth])
	  @user.valid?
	  puts 'check reg params'
	  puts params
	end
end
