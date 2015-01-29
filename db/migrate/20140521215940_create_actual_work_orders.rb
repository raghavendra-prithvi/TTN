class CreateActualWorkOrders < ActiveRecord::Migration
  def change
    create_table :actual_work_orders do |t|      
        t.string 'work_order_id'
        t.string 'project_description'
        t.string 'program_office'
        t.integer 'project_manager_id'
        t.date 'start_date'
        t.date 'end_date'
        t.string 'work_order_status'
        t.string 'work_progress_status'
    end
  end
end
