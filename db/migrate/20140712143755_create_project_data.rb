class CreateProjectData < ActiveRecord::Migration
  def change
    create_table :project_data do |t|
	  t.integer 'project_id'
	  t.string 'name'
	  t.string 'type'
	  t.string 'description'
	  t.boolean 'active', :default => true
      t.timestamps
    end
  end
end
