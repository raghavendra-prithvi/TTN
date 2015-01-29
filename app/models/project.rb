class Project < ActiveRecord::Base
attr_accessible :id, :name, :category, :acct_number, :active, :project_datas_attributes,
		:created_at, :updated_at
		
has_many :project_datas


accepts_nested_attributes_for :project_datas

def self.alphaNum
	order('acct_number ASC')
end

end
