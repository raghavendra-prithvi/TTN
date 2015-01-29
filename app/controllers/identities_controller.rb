class IdentitiesController < ApplicationController
  def new
		puts env['omniauth.identity']
    @identity = env['omniauth.identity']
  end
end
