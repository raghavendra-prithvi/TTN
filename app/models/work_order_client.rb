class WorkOrderClient < ActiveRecord::Base
attr_accessible :user_id, :work_order_id, :created_at, :updated_at


belongs_to :user	
belongs_to :work_order





end
