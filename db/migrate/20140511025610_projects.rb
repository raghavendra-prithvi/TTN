class Projects < ActiveRecord::Migration
  def change
    create_table "projects", force: true do |t|
      t.string "name"
      t.string "category"
      t.string "project_id"
      t.string "acct_number"
      t.boolean "active", default: true
      t.integer "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
