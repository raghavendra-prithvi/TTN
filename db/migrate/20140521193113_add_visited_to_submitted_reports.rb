class AddVisitedToSubmittedReports < ActiveRecord::Migration
  def change
    add_column :submitted_reports, :visited, :boolean, :default => false
  end
end
