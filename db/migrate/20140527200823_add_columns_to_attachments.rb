class AddColumnsToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :about, :string
    add_column :attachments, :title, :string
    add_column :attachments, :attachment, :binary
  end
end
