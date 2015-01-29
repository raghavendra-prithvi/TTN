class ArchievedProject < ActiveRecord::Base
attr_accessible :id, :project_data_id, :name, :category, :acct_number, :user_id

has_many :assigned_projects
has_many :project_managers


def assigned_projects
	pdId = self.project_data_id
	return AssignedProject.where(:project_data_id => pdId)
end

def time_tables
	pdId = self.project_data_id
	return TimeTable.where(:project_data_id => pdId)
end

def get_user_name
	user_id = self.user_id
	user = User.where(:id => user_id)
	if user.blank?
		return DisabledUser.where(:user_id => user_id).first.name
	else
		return user.first.name
	end
end
  
  def getAcctNumber
    return self.acct_number
  end

end
