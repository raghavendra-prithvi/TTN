class AlterProjectsTable < ActiveRecord::Migration
  def change
  	remove_column :projects, :category
  	add_column :projects, :secondary_acct_number, :string
  	change_column :work_orders, :work_order_number, :string
  end
end
