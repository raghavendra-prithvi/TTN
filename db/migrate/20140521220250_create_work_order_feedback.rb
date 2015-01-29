class CreateWorkOrderFeedback < ActiveRecord::Migration
  def change
    create_table :work_order_feedback do |t|      
         t.integer 'work_order_id'
         t.integer 'client_id'
         t.integer 'admin_id'
         t.string 'feedback'
         t.timestamps
    end
  end
end
