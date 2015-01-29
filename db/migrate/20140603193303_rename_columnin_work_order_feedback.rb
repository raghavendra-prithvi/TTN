class RenameColumninWorkOrderFeedback < ActiveRecord::Migration
  def change
  	rename_column :work_order_feedbacks, :client_id, :work_order_client_id
  end
end
