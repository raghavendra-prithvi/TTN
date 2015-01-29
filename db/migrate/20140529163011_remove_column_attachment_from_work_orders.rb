class RemoveColumnAttachmentFromWorkOrders < ActiveRecord::Migration
  def change
  	remove_column :work_orders, :attachment
  end
end
