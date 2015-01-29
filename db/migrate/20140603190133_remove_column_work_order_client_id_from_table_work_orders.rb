class RemoveColumnWorkOrderClientIdFromTableWorkOrders < ActiveRecord::Migration
  def change
  	remove_column :work_orders, :work_order_client_id
  end
end
