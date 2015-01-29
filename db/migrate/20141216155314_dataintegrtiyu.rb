class Dataintegrtiyu < ActiveRecord::Migration
  def change

	  ActualWorkOrder.columns.each do |column|
			change_column_null :actual_work_orders, column.name, false
		end	
  end
end
