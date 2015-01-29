class AssignedProject < ActiveRecord::Base
attr_accessible :project_data_id, :user_id, :created_at, :updated_at

belongs_to :user
belongs_to :project_data
belongs_to :archieved_project

def self.alpha
	joins(:project_data).order("project_data.name ASC")
end

def self.alphaArchived
	joins("JOIN archieved_projects ON archieved_projects.project_data_id = assigned_projects.project_data_id")
end

def self.enabled_users
	joins(:user)
end

end
