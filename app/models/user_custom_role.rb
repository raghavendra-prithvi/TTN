class UserCustomRole < ActiveRecord::Base

	belongs_to :custom_role
	belongs_to :user


end
