class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :ull_team_members do |t|
        t.integer 'work_order_requests_id'
        t.string 'name'
    end
  end
end
