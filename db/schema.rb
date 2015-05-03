# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141217224337) do

  create_table "actual_work_orders", force: true do |t|
    t.integer "work_order_id",        limit: 255, null: false
    t.string  "project_description",              null: false
    t.date    "start_date",                       null: false
    t.date    "end_date",                         null: false
    t.string  "work_order_status",                null: false
    t.string  "work_progress_status",             null: false
    t.integer "estimated_hours",                  null: false
    t.integer "project_data_id",                  null: false
  end

  create_table "archieved_projects", force: true do |t|
    t.string   "name",                        null: false
    t.string   "category",                    null: false
    t.integer  "project_data_id", limit: 255, null: false
    t.string   "acct_number",                 null: false
    t.integer  "user_id",                     null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "assigned_projects", force: true do |t|
    t.integer  "project_data_id", null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "attachments", force: true do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "about"
    t.string   "title"
    t.string   "attachment",    null: false
    t.integer  "work_order_id", null: false
    t.string   "avatar",        null: false
  end

  create_table "custom_roles", force: true do |t|
    t.string  "role_name",               null: false
    t.string  "description",             null: false
    t.integer "ranking",     default: 0, null: false
  end

  create_table "disabled_users", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "email",      null: false
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "role",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identities", force: true do |t|
    t.string   "name",            null: false
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "role",            null: false
  end

  create_table "internal_project_acct_numbers", force: true do |t|
    t.integer  "project_data_id", null: false
    t.string   "acct_number",     null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "project_data", force: true do |t|
    t.integer  "project_id"
    t.string   "name",                             null: false
    t.string   "project_type",                     null: false
    t.string   "description",                      null: false
    t.boolean  "active",            default: true, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "prev_month_locked",                null: false
    t.boolean  "locked",                           null: false
  end

  create_table "project_managers", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "project_data_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "projects", force: true do |t|
    t.string   "name",                  limit: 500
    t.string   "acct_number"
    t.boolean  "active",                            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secondary_acct_number"
  end

  create_table "reporters", id: false, force: true do |t|
    t.integer "id"
    t.integer "reporter_id",                 null: false
    t.integer "reported_id",                 null: false
    t.boolean "submitted",   default: false, null: false
    t.boolean "approved",    default: false, null: false
  end

  create_table "submitted_reports", force: true do |t|
    t.string   "month",                        null: false
    t.integer  "report_for",                   null: false
    t.integer  "submitted_to"
    t.boolean  "approved",     default: false
    t.boolean  "rejected",     default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "visited",      default: false, null: false
    t.string   "feedback"
  end

  create_table "time_modified_reports", force: true do |t|
    t.integer "reporting_user",   null: false
    t.integer "modified_manager", null: false
    t.integer "modified_hours",   null: false
    t.text    "comments",         null: false
    t.integer "project_data_id",  null: false
    t.string  "month",            null: false
    t.string  "year",             null: false
  end

  create_table "time_tables", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "project_data_id", null: false
    t.date     "date",            null: false
    t.float    "hours",           null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "modified_hours",  null: false
  end

  create_table "ull_team_members", force: true do |t|
    t.string  "name",          null: false
    t.integer "work_order_id", null: false
  end

  create_table "user_custom_roles", force: true do |t|
    t.integer "user_id"
    t.integer "custom_role_id"
  end

  create_table "user_permissions", force: true do |t|
    t.boolean "all_access",                    null: false
    t.boolean "activate_all_projects",         null: false
    t.boolean "activate_managed_projects",     null: false
    t.boolean "archive_all_projects",          null: false
    t.boolean "archive_managed_projects",      null: false
    t.boolean "assign_users_all_projects",     null: false
    t.boolean "assign_users_managed_projects", null: false
    t.boolean "create_projects",               null: false
    t.boolean "destroy_projects",              null: false
    t.boolean "remove_users",                  null: false
    t.boolean "add_users",                     null: false
    t.boolean "edit_users",                    null: false
    t.boolean "edit_projects",                 null: false
    t.integer "custom_role_id",                null: false
  end

  create_table "users", id: false, force: true do |t|
    t.string   "name",                                                null: false
    t.string   "email",                                               null: false
    t.string   "role",                                                null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "password_digest",                                     null: false
    t.string   "remember_token",                                      null: false
    t.string   "avatars"
    t.string   "country"
    t.boolean  "admin",                               default: false, null: false
    t.string   "confirmed",                                           null: false
    t.string   "signer"
    t.string   "shares"
    t.string   "provider"
    t.string   "uid",                                                 null: false
    t.boolean  "manager",                             default: false, null: false
    t.integer  "reporter"
    t.integer  "reported_by"
    t.boolean  "updated",                             default: false, null: false
    t.boolean  "active",                              default: false
    t.string   "token"
    t.string   "first_name",                                          null: false
    t.string   "last_name",                                           null: false
    t.boolean  "time_sheet_manager",                  default: false, null: false
    t.boolean  "client",                  limit: 255, default: false
    t.boolean  "work_order_admin",                    default: false, null: false
    t.boolean  "time_sheet_collaborator",             default: false, null: false
    t.boolean  "project_admin",                       default: false, null: false
    t.boolean  "locked",                              default: false, null: false
    t.boolean  "prev_month_locked",                   default: true,  null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  create_table "work_order_clients", force: true do |t|
    t.integer "user_id",       null: false
    t.integer "work_order_id", null: false
  end

  create_table "work_order_feedbacks", force: true do |t|
    t.integer  "work_order_id", null: false
    t.integer  "admin_id",      null: false
    t.string   "feedback",      null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "work_orders", force: true do |t|
    t.string  "work_order_number"
    t.string  "project_name"
    t.string  "work_order_type"
    t.string  "UNO_project_manager"
    t.string  "business_owner"
    t.string  "program_office"
    t.date    "due_date"
    t.date    "ULL_start_date"
    t.date    "development_end_date"
    t.date    "close_date"
    t.integer "estimated_hours"
    t.string  "ULL_contact"
    t.string  "summary"
    t.string  "deliverables"
    t.string  "comments"
    t.boolean "approved",             default: false
    t.boolean "submitted",            default: false
  end

end
