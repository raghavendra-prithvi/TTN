class AddRankingToCustomRoles < ActiveRecord::Migration
  def change
    add_column :custom_roles, :ranking, :integer
  end
end
