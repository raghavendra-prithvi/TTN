module SessionsHelper

  def sign_in(user)
    cookies[:remember_token] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !session[:user_id].nil? 
  end

    def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    #@current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end


	
  

    def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
	end



 def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  	def confirm(user)
		user.confirmed = "t"
		user.save
	end


	def save_friend
		emails = params[:to].to_s
		section = emails.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i)
		a = 0
		user = current_user.id
		section.each do
		email = section[a]
		@friend = Friend.new(:email => email, :user_id => user)
		@friend.save
		a =+ 1
		current_user.shares = current_user.shares.to_i + 1
		current_user.save
		end
	end

	def doneshare(user)
		user.shares = 5
		user.save
	end


end
