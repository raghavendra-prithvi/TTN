class AddFeedBackToGaReport < ActiveRecord::Migration
  def change
    add_column :submitted_reports, :feedback, :string
  end
end
