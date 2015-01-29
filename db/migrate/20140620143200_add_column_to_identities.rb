class AddColumnToIdentities < ActiveRecord::Migration
  def change
  	add_column :identities, :role, :string
  end
end
