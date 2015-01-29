class CreateSubmittedReports < ActiveRecord::Migration
  def change
    create_table :submitted_reports do |t|
      t.string :month
      t.integer :report_for
      t.integer :submitted_to
      t.boolean :approved, :default => false
      t.boolean :rejected, :default => false
      
      t.timestamps
    end
  end
end
