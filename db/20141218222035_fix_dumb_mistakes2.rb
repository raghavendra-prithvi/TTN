class FixDumbMistakes2 < ActiveRecord::Migration
  def change 
    change_table :users do |t|
		  t.primary_key :id
    end
  end
end
