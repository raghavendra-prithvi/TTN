class ChangeColumnTypeinActualWorkOrders < ActiveRecord::Migration
  def change
  	change_column :actual_work_orders, :work_order_id, :integer
  end
end
