class TimeTables < ActiveRecord::Migration
  def change
    create_table "time_tables", force: true do |t|
      t.integer "user_id"
      t.integer "project_id"
      t.date "date"
      t.float "hours"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
