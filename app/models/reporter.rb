class Reporter < ActiveRecord::Base
  attr_accessible :reporter_id, :reported_id, :submitted, :approved, :id
  belongs_to :user
end
