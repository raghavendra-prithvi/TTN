class CreateInternalProjectAcctNumbers < ActiveRecord::Migration
  def change
    create_table :internal_project_acct_numbers do |t|
	  t.integer 'project_data_id'
	  t.string 'acct_number'
      t.timestamps
    end
  end
end
