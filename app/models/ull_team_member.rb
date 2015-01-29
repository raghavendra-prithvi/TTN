class UllTeamMember < ActiveRecord::Base
attr_accessible :work_order_id, :name, :id, :_destroy
belongs_to :work_order
end
