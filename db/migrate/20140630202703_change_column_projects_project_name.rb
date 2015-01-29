class ChangeColumnProjectsProjectName < ActiveRecord::Migration
  def change
  	change_column :projects, :name, :string, :limit => 500
  end
end
