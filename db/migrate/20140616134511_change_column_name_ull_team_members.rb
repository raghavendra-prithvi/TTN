class ChangeColumnNameUllTeamMembers < ActiveRecord::Migration
  def change
  	remove_column :ull_team_members, :work_order_requests_id
  	add_column :ull_team_members, :work_order_id, :integer
  end
end
