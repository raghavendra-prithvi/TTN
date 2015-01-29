class EmoveRecentUpdates < ActiveRecord::Migration
  def change
  	remove_column :assigned_projects, :date_unassigned
  	remove_column :assigned_projects, :date_assigned
  	remove_column :project_managers, :date_unassigned
  	remove_column :project_managers, :date_assigned
  end
end
