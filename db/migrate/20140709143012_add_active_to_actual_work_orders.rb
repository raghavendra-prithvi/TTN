class AddActiveToActualWorkOrders < ActiveRecord::Migration
  def change
  	add_column :actual_work_orders, :active, :boolean, :default => true
  end
end
