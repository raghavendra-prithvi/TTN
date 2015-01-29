class CreateWorkOrderProjectManagers < ActiveRecord::Migration
  def change
    create_table :work_order_project_managers do |t|
	  t.integer 'user_id'
	  t.integer 'actual_work_order_id'
      t.timestamps
    end
  end
end
