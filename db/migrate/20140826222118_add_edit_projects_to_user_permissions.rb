class AddEditProjectsToUserPermissions < ActiveRecord::Migration
  def change
    add_column :user_permissions, :edit_projects, :boolean
  end
end
