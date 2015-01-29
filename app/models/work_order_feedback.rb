class WorkOrderFeedback < ActiveRecord::Base
attr_accessible  :work_order_id, :work_order_client_id, :admin_id, :feedback, :created_at, :updated_at

belongs_to :work_order
belongs_to :user

end

