class InternalProjectManager < ActiveRecord::Base
attr_accessible :internal_project_id, :user_id, :id
belongs_to :internal_project
end
