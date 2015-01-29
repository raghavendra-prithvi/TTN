class AddWorkOrderAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :work_order_admin, :boolean, :default => false
  end
end
