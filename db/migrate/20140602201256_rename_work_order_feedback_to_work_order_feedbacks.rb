class RenameWorkOrderFeedbackToWorkOrderFeedbacks < ActiveRecord::Migration
  def change
  	rename_table :work_order_feedback, :work_order_feedbacks
  end
end
