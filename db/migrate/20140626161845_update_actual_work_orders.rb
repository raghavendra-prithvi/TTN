class UpdateActualWorkOrders < ActiveRecord::Migration
  def change
  	add_column :actual_work_orders, :estimated_hours, :integer
  end
end
