class AddColumnsToUser3 < ActiveRecord::Migration
  def change
  	add_column :users, :locked, :boolean, :default => false
  	add_column :users, :prev_month_locked, :boolean, :default => true
  end
end
