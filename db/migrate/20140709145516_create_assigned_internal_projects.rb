class CreateAssignedInternalProjects < ActiveRecord::Migration
  def change
    create_table :assigned_internal_projects do |t|
		t.integer 'internal_project_id'
		t.integer 'user_id'
      t.timestamps
    end
  end
end
