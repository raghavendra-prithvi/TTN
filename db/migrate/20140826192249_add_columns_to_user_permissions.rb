class AddColumnsToUserPermissions < ActiveRecord::Migration
  def change
    add_column :user_permissions, :remove_users, :boolean
    add_column :user_permissions, :add_users, :boolean
  end
end
