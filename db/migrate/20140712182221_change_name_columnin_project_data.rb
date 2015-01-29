class ChangeNameColumninProjectData < ActiveRecord::Migration
  def change
  	rename_column :project_data, :type, :project_type
  end
end
