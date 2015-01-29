class CreateArchievedProjects < ActiveRecord::Migration
  def change
    create_table :archieved_projects do |t|
      t.string   "name"
      t.string   "category"
      t.string   "project_id"
      t.string   "acct_number"      
      t.integer  "user_id"
      t.timestamps
    end
  end
end
