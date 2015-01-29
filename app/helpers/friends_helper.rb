module FriendsHelper
  
  def shared(friendsdone)
    current_user.shares = friendsdone
	current_user.save
  end  
  
end