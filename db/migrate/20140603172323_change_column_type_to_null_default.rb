class ChangeColumnTypeToNullDefault < ActiveRecord::Migration
  def change
    	change_column :work_orders, :approved, :boolean, :null => true
  		change_column :work_orders, :submitted, :boolean, :null => true
  end
end
