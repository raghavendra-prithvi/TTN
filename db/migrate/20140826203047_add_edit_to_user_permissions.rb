class AddEditToUserPermissions < ActiveRecord::Migration
  def change
    add_column :user_permissions, :edit_users, :boolean
  end
end
