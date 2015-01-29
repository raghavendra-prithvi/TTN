class Attachment < ActiveRecord::Base
mount_uploader :attachment, AttachmentUploader
belongs_to :work_order

attr_accessible :about, :title, :attachment, :id, :work_order_id
	
	

end
