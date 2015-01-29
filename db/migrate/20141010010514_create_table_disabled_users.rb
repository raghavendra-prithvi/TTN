class CreateTableDisabledUsers < ActiveRecord::Migration
  def change
    create_table :disabled_users do |t|
      t.integer :user_id
      t.string :email
      t.string :first_name
      t.string :last_name
    end
  end
end
