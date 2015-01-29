class ChangeColumnInCustomRoles < ActiveRecord::Migration
  def change
  	change_column :custom_roles, :ranking, :integer, :default => 0
  end
end
