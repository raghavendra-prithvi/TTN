class AddColumnToDisabledUser < ActiveRecord::Migration
  def change
    add_column :disabled_users, :role, :string
  end
end
