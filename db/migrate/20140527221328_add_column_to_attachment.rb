class AddColumnToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :work_order_id, :integer
  end
end
