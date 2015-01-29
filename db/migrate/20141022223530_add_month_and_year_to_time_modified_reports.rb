class AddMonthAndYearToTimeModifiedReports < ActiveRecord::Migration
  def change
    add_column :time_modified_reports, :month, :string
    add_column :time_modified_reports, :year, :string
  end
end
