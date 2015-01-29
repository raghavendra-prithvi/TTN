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

ActiveRecord::Schema.define(version: 20141219004254) do

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
    t.string   "name"
    t.string   "category"
    t.integer  "project_data_id", limit: 255
    t.string   "acct_number"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assigned_projects", force: true do |t|
    t.integer  "project_data_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "about"
    t.string   "title"
    t.string   "attachment"
    t.integer  "work_order_id"
    t.string   "avatar"
  end

  create_table "custom_roles", force: true do |t|
    t.string  "role_name"
    t.string  "description"
    t.integer "ranking",     default: 0
  end

  create_table "disabled_users", force: true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identities", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  create_table "internal_project_acct_numbers", force: true do |t|
    t.integer  "project_data_id"
    t.string   "acct_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "project_data", force: true do |t|
    t.integer  "project_id",        default: 1
    t.string   "name",              default: "t",  null: false
    t.string   "project_type",      default: "t",  null: false
    t.string   "description",       default: "t",  null: false
    t.boolean  "active",            default: true, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "prev_month_locked", default: true, null: false
    t.boolean  "locked",            default: true, null: false
  end

  create_table "project_managers", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_data_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "name",                  limit: 500
    t.string   "acct_number"
    t.boolean  "active",                            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "secondary_acct_number"
  end

  create_table "reporters", force: true do |t|
    t.integer "reporter_id", limit: 255
    t.integer "reported_id", limit: 255
    t.boolean "submitted",   limit: 255, default: false
    t.boolean "approved",    limit: 255, default: false
  end

  create_table "submitted_reports", force: true do |t|
    t.string   "month"
    t.integer  "report_for"
    t.integer  "submitted_to"
    t.boolean  "approved",     default: false
    t.boolean  "rejected",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "visited",      default: false
    t.string   "feedback"
  end

  create_table "time_modified_reports", force: true do |t|
    t.integer "reporting_user"
    t.integer "modified_manager"
    t.integer "modified_hours"
    t.text    "comments"
    t.integer "project_data_id"
    t.string  "month"
    t.string  "year"
  end

  create_table "time_tables", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_data_id"
    t.date     "date"
    t.float    "hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "modified_hours"
  end

  create_table "ull_team_members", force: true do |t|
    t.string  "name"
    t.integer "work_order_id"
  end

  create_table "user_custom_roles", force: true do |t|
    t.integer "user_id"
    t.integer "custom_role_id"
  end

  create_table "user_permissions", force: true do |t|
    t.boolean "all_access"
    t.boolean "activate_all_projects"
    t.boolean "activate_managed_projects"
    t.boolean "archive_all_projects"
    t.boolean "archive_managed_projects"
    t.boolean "assign_users_all_projects"
    t.boolean "assign_users_managed_projects"
    t.boolean "create_projects"
    t.boolean "destroy_projects"
    t.boolean "remove_users"
    t.boolean "add_users"
    t.boolean "edit_users"
    t.boolean "edit_projects"
    t.integer "custom_role_id"
  end

  create_table "users", force: true do |t|
    t.string   "name",                                default: "t"
    t.string   "email",                               default: "t"
    t.string   "role",                                default: "t"
    t.datetime "created_at",              limit: 255
    t.datetime "updated_at",              limit: 255
    t.string   "password_digest",                     default: "t"
    t.string   "remember_token",                      default: "t"
    t.string   "avatars",                             default: "t"
    t.string   "country",                             default: "t"
    t.boolean  "admin",                   limit: 255, default: true
    t.string   "confirmed",                           default: "t"
    t.string   "signer",                              default: "t"
    t.string   "shares",                              default: "t"
    t.string   "provider",                            default: "t"
    t.string   "uid",                                 default: "t"
    t.boolean  "manager",                 limit: 255, default: true
    t.integer  "reporter",                limit: 255, default: 1
    t.integer  "reported_by",             limit: 255, default: 1
    t.boolean  "updated",                 limit: 255, default: true
    t.boolean  "active",                  limit: 255, default: true
    t.string   "token",                               default: "t"
    t.string   "first_name",                          default: "t"
    t.string   "last_name",                           default: "t"
    t.boolean  "time_sheet_manager",      limit: 255, default: true
    t.boolean  "client",                  limit: 255, default: true
    t.boolean  "work_order_admin",        limit: 255, default: true
    t.boolean  "time_sheet_collaborator", limit: 255, default: true
    t.boolean  "project_admin",           limit: 255, default: true
    t.boolean  "locked",                  limit: 255, default: true
    t.boolean  "prev_month_locked",       limit: 255, default: true
    t.string   "password_reset_token",                default: "t"
    t.datetime "password_reset_sent_at",  limit: 255
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
