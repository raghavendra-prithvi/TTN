class AddColumnToWorkOrder < ActiveRecord::Migration
  def change
  	add_column :work_orders, :work_order_client_id, :integer
  end
end
