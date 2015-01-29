class RemoveColumnsFromMultiple < ActiveRecord::Migration
  
  def change
  	remove_column :custom_roles, :user_permission_id
  	add_column :user_permissions, :custom_role_id, :integer
  end
end
