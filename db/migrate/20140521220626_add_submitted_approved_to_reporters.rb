class AddSubmittedApprovedToReporters < ActiveRecord::Migration
  def change
    add_column :reporters, :submitted, :boolean, :default => false
    add_column :reporters, :approved, :boolean, :default => false    
  end
end
