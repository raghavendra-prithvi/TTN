class CreateNewUserPermissions < ActiveRecord::Migration
  def change 	
  	
    create_table :user_permissions do |t|
    	t.integer 'user_id'
    	t.boolean 'all_access'
    	t.boolean 'activate_all_projects'
    	t.boolean 'activate_managed_projects'
    	t.boolean 'archive_all_projects'
    	t.boolean 'archive_managed_projects'
    	t.boolean 'assign_users_all_projects'
    	t.boolean 'assign_users_managed_projects'
    	t.boolean 'create_projects'
    	t.boolean 'destroy_projects'
    end
  end
end
