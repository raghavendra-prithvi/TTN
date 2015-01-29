class InternalProjectManagers < ActiveRecord::Migration
  def change
    create_table :internal_project_managers do |t|
        t.integer 'internal_project_id'
        t.integer 'user_id'
    end

  end
end
