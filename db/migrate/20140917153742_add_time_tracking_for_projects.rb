class AddTimeTrackingForProjects < ActiveRecord::Migration
  def change
  	add_column :project_managers, :date_assigned, :date
  	add_column :project_managers, :date_unassigned, :date
  	add_column :assigned_projects, :date_assigned, :date
  	add_column :assigned_projects, :date_unassigned, :date  	
  end
end
