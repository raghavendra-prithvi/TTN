class AddTableInternalProjects < ActiveRecord::Migration
  def change
    create_table :internal_projects do |t|
        t.integer 'project_id'
        t.string 'title'
        t.string 'description'
    end
	end
end
 
