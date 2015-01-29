class SubmittedReport < ActiveRecord::Base
attr_accessible :month, :report_for, :submitted_to, :approved, :rejected, :created_at, :updated_at, :visited

end
