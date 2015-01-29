class ProjectData < ActiveRecord::Base
attr_accessible :id, :name, :project_type, :active, :project_managers_attributes, :actual_work_orders_attributes,
				:assigned_projects_attributes,
		:created_at, :updated_at
	
belongs_to :project
has_many :assigned_projects
has_many :time_tables
has_many :actual_work_orders
has_many :project_managers
has_one :internal_project_acct_number

  validates_uniqueness_of :name
  validates_presence_of :name

accepts_nested_attributes_for :project_managers
accepts_nested_attributes_for :actual_work_orders
accepts_nested_attributes_for :assigned_projects


def getAcctNumber
	if !self.project.nil?
		return self.project.acct_number
	elsif !self.internal_project_acct_number.nil?
		return self.internal_project_acct_number.acct_number
	else
		return ''
	end
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

default_scope :order => 'name ASC' 


end
