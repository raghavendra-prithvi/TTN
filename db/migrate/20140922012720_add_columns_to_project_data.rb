class AddColumnsToProjectData < ActiveRecord::Migration
  def change
    add_column :project_data, :prev_month_locked, :boolean
    add_column :project_data, :locked, :boolean
  end
end
