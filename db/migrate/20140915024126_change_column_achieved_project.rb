class ChangeColumnAchievedProject < ActiveRecord::Migration
  def change
  	change_column :archieved_projects, :project_data_id, :integer
  end
end
