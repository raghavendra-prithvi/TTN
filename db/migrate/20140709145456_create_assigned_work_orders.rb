class CreateAssignedWorkOrders < ActiveRecord::Migration
  def change
    create_table :assigned_work_orders do |t|
    	t.integer 'actual_work_order_id'
    	t.integer 'user_id'

      t.timestamps
    end
  end
end
