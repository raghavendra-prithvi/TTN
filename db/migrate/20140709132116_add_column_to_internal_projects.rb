class AddColumnToInternalProjects < ActiveRecord::Migration
  def change
  	add_column :internal_projects, :active, :boolean, :default => true
  end
end
