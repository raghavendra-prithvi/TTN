class ChangeTableUserCreateColumnProjectAdmin < ActiveRecord::Migration
  def change
  	add_column :users, :project_admin, :boolean, :default => false
  end
end
