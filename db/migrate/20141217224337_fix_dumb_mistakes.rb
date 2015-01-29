class FixDumbMistakes < ActiveRecord::Migration
  def change

		User.columns.each do |column|
			if ["created_at", "updated_at", "password_reset_sent_at"].include?(column.name)
				change_column :users, column.name, :datetime
			
			elsif ["admin", "manager", "updated", "active", "time_sheet_manager", "client", "work_order_admin", "time_sheet_collaborator", "project_admin", "locked", "prev_month_locked"].include?(column.name)
				if column.name == 'prev_month_locked'
					change_column :users, column.name, :boolean, :default => true
				else
					change_column :users, column.name, :boolean, :default => false
				end
			elsif ["reporter", "reported_by"].include?(column.name)
					change_column :users, column.name, :integer
			elsif column.name == "id"
					remove_column :users, column.name
			end
		end
 
		Reporter.columns.each do |column|
			if ["submitted", "approved"].include?(column.name)
				change_column :reporters, column.name, :boolean, :default => false
			else
				change_column :reporters, column.name, :integer
			end
		end


 end
end
