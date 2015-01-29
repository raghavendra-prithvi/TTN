class RemoveColumnsFromActualWorkOrder < ActiveRecord::Migration
  def change
      remove_column :actual_work_orders, :program_office
      remove_column :actual_work_orders, :project_manager_id

  end
end
