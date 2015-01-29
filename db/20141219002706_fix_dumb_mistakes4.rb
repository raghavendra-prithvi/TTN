class FixDumbMistakes4 < ActiveRecord::Migration
  def change

		
  remove_column :reporters, :id
	add_column :reporters, :id, :primary_key

  end
end
