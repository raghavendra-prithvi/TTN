class CreateWorkOrderProjects < ActiveRecord::Migration
  def change
    create_table :work_order_projects do |t|
       t.integer "project_id"
       t.integer "work_order_id"
    end
  end
end
