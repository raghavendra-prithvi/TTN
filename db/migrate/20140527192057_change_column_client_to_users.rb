class ChangeColumnClientToUsers < ActiveRecord::Migration
  def change
    change_column :users, :client, :boolean
  end
end
