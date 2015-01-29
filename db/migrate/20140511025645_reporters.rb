class Reporters < ActiveRecord::Migration
  def change
    create_table "reporters", force: true do |t|
      t.integer "reporter_id"
      t.integer "reported_id"    
    end
  end
end
