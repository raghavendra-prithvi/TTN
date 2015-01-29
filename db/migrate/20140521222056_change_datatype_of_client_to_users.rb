class ChangeDatatypeOfClientToUsers < ActiveRecord::Migration
  def change
    change_column :users, :client, :boolean
  end
end
