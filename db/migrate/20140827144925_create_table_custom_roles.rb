class CreateTableCustomRoles < ActiveRecord::Migration
  def change
    create_table :custom_roles do |t|
    	t.string 'role_name'
    	t.string 'description'
    	t.integer 'user_permission_id'
    end
    
    create_table :user_custom_roles do |t|
    	t.integer 'user_id'
    	t.integer 'custom_role_id'
    end
    
    remove_column :user_permissions, :user_id
  end
end
