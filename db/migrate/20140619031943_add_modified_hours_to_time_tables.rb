class AddModifiedHoursToTimeTables < ActiveRecord::Migration
  def change
    add_column :time_tables, :modified_hours, :integer
  end
end
