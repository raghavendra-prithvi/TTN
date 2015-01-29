class DisabledUser < ActiveRecord::Base
attr_accessible :user_id, :first_name, :last_name, :email, :id, :role

belongs_to :user
belongs_to :project_data
belongs_to :archieved_project


def self.alpha
	joins(:project_data).order("project_data.name ASC")
end

def name
	self.first_name + ' ' + self.last_name
end

def time_tables
	TimeTable.where(:user_id => self.user_id)
	end

end
