class RemoveColumnProjectIdFromProjects < ActiveRecord::Migration
  def change
  	remove_column :projects, :project_id
  end
end
