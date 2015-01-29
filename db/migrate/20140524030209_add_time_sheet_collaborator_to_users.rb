class AddTimeSheetCollaboratorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_sheet_collaborator, :boolean, :default => false
  end
end
