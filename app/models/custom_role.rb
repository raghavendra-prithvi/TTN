class CustomRole < ActiveRecord::Base

	has_many :user_custom_roles
	has_one :user_permission

def self.orderRanking
	order("ranking ASC, role_name ASC")
end
	


end
