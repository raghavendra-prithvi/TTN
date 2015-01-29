Rails.application.config.middleware.use OmniAuth::Builder do
  provider :identity, on_failed_registration: lambda { |env|
  		puts env
  		if env['QUERY_STRING'] == 'client=true'
  		SessionsController.action(:new_client).call(env)
    	else 
    		SessionsController.action(:new).call(env)
    	end
  }    
end
# OmniAuth.config.on_failure = Proc.new { |env|
#   OmniAuth::FailureEndpoint.new(env).redirect_to_failure
# }