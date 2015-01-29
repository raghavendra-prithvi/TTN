class RemoveColumnFromWorkOrder < ActiveRecord::Migration
  def change
    remove_column :work_orders, :attachments, :string
  end
end
