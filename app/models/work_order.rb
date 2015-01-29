class WorkOrder < ActiveRecord::Base
has_many :work_order_clients
has_many :users, :through => :work_order_clients
has_many :attachments
has_many :work_order_feedbacks, :dependent => :destroy
has_one :actual_work_order
has_one :project_data, :through => :actual_work_order
has_many :ull_team_members, :dependent => :destroy

accepts_nested_attributes_for :attachments
accepts_nested_attributes_for :ull_team_members, allow_destroy: true

attr_accessible :work_order_number, :project_name, :work_order_type, :UNO_project_manager, 
				:business_owner, :program_office, :due_date, :ULL_start_date, :development_end_date, 
      			:close_date, :estimated_hours, :ULL_contact, :summary, :deliverables, :comments, 
      			:attachments_attributes, :ull_team_members_attributes, :id

def self.alpha
	order(:work_order_number, :project_name)
end

def self.sort_by_type
	order(:work_order_type)
end

################################## JOIN USERS TABLE TO IGNORE DISABLED
def self.submitted 
	where(:submitted=>true, :approved=>false).joins(:users)
end

def self.approved
	where(:submitted=> true, :approved => true).joins(:users)
end

def self.resubmit
	where(:submitted=>false, :approved=>nil).joins(:users)
end

def self.rejected
	where(:submitted=>nil, :approved=>false).joins(:users)
end


def self.cancelled
	where(:submitted=>nil, :approved=>nil).joins(:users)
end

def self.saved
	where(:submitted=>false, :approved=>false).joins(:users)
end

####### ALL USERS CONSIDERED
def self.submitted_all_users 
	where(:submitted=>true, :approved=>false)
end

def self.approved_all_users
	where(:submitted=> true, :approved => true)
end

def self.resubmit_all_users
	where(:submitted=>false, :approved=>nil)
end

def self.rejected_all_users
	where(:submitted=>nil, :approved=>false)
end


def self.cancelled_all_users
	where(:submitted=>nil, :approved=>nil)
end

def self.saved_all_users
	where(:submitted=>false, :approved=>false)
end
############

def self.is_type_project
	where(:work_order_type => 'project')
end

def self.is_type_support
	where(:work_order_type => 'support')
end

def self.is_type_maintenance
	where(:work_order_type => 'maintenance')
end

def self.is_type_admin
	where(:work_order_type => 'admin')
end




def self.is_medicaid
	where(:program_office => 'medicaid')
end

def self.is_oph
	where(:program_office => 'oph')
end

def self.is_obh
	where(:program_office => 'obh')
end

def self.is_oaas
	where(:program_office => 'oaas')
end

def self.is_ocdd
	where(:program_office => 'ocdd')
end

def self.is_os
	where(:program_office => 'os')
end

end
