class ChangeColumnType < ActiveRecord::Migration
  def change
  	change_column :work_orders, :approved, :boolean
  	change_column :work_orders, :submitted, :boolean
  end
end
