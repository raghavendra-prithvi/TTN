class ProjectManager < ActiveRecord::Base
attr_accessible :user_id, :project_data_id, :id

belongs_to :user
belongs_to :project_data
belongs_to :archieved_project


def self.alpha
	joins(:project_data).order("project_data.name ASC")
end

def self.enabled_users
	joins(:user)
end


end
