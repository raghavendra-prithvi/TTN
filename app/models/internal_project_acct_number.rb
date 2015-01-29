class InternalProjectAcctNumber < ActiveRecord::Base
attr_accessible :id, :project_data_id, :acct_number,
		:created_at, :updated_at
	
belongs_to :project_data


end
