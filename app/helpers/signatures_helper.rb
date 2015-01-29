module SignaturesHelper

	
	
	def test
		if current_user.signer == "yes"
		return true
		end
	end
	
	def find
		@petitions = Petition.find(:all)
		@petitions.each do |petition| 
			if petition.pass == "pass"
				return petition
			end	
		end
	end	
	
	def find2
		@petitions = Petition.find(:all)
		@petitions.each do |petition| 
			if petition.launched == "yes"
				return petition
			end	
		end
	end		
	
  # this method will embed the code from the partial
  def youtube_video(url)
    render :partial => 'shared/video', :locals => { :url => url }
  end 
  
  def signature(user)
    user.signer = "yes"
	user.save
  end  
  
    def shared(friendsdone)
    current_user.shares = friendsdone
	current_user.save
  end 
end