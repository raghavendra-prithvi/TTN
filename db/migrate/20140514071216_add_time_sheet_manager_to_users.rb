class AddTimeSheetManagerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_sheet_manager, :boolean, :default => false
  end
end
