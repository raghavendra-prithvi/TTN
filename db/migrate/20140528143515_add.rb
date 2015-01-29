class Add < ActiveRecord::Migration
  def change
  	add_column :work_orders, :attachment, :string
  end
end
