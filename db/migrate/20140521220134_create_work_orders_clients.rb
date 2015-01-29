class CreateWorkOrdersClients < ActiveRecord::Migration
  def change
    create_table :work_order_clients do |t|     
         t.integer 'user_id'
         t.integer 'work_order_id'
    end
  end
end
