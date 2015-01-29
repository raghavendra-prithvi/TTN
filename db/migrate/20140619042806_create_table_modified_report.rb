class CreateTableModifiedReport < ActiveRecord::Migration
  def change
    create_table :time_modified_reports do |t|
      t.integer :reporting_user
      t.integer :modified_manager
      t.integer :modified_hours
      t.text :comments
      t.integer :project
    end
  end
end
