class ChangeAttachmentTypeInAttachments < ActiveRecord::Migration
  def change
  	change_column :attachments, :attachment, :string
  end
end
