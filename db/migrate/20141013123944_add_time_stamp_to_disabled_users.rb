class AddTimeStampToDisabledUsers < ActiveRecord::Migration
  def change
  	add_column :disabled_users, :created_at, :datetime
  	add_column :disabled_users, :updated_at, :datetime
  end
end
