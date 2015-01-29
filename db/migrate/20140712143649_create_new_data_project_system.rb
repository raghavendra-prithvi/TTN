class CreateNewDataProjectSystem < ActiveRecord::Migration
  def change
    drop_table :assigned_internal_projects
    drop_table :assigned_work_orders
    drop_table :internal_project_managers
    drop_table :internal_projects
    drop_table :work_order_project_managers
    drop_table :work_order_projects
    
    rename_column :archieved_projects, :project_id, :project_data_id
    rename_column :assigned_projects, :project_id, :project_data_id
    rename_column :project_managers, :project_id, :project_data_id
    rename_column :time_modified_reports, :project, :project_data_id
    rename_column :time_tables, :project_id, :project_data_id
	
	add_column :actual_work_orders, :project_data_id, :integer
	remove_column :actual_work_orders, :active

    
  end
end
