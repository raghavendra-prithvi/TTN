class RemoveWorkOrderClientFromFeedback < ActiveRecord::Migration
  def change
  	remove_column :work_order_feedbacks, :work_order_client_id
  end
end
