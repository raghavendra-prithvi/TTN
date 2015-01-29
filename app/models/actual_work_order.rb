class ActualWorkOrder < ActiveRecord::Base
attr_accessible :work_order_id, :project_description, :program_office, :project_manager_id, :start_date, :end_date,
				:work_order_status, :work_progress_status, :project_data_id

belongs_to :work_order
belongs_to :project_data

def self.sort_by_type
	joins(:work_order).order("work_order_type")
end

end
