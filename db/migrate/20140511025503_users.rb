class Users < ActiveRecord::Migration
  def change
    create_table "users", force: true do |t|
      t.string "name"
      t.string "email"
      t.string "role"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "password_digest"
      t.string "remember_token"
      t.string "avatars"
      t.string "country"
      t.boolean "admin", default: false
      t.string "confirmed"
      t.string "signer"
      t.string "shares"
      t.string "provider"
      t.string "uid"
      t.boolean "manager", default: false
      t.integer "reporter" 
      t.integer "reported_by"
      t.boolean  "updated", default: false
      t.boolean "active", default: false
      t.string "token"
    end
  end
end
