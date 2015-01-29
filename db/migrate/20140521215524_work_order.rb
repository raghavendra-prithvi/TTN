class WorkOrder < ActiveRecord::Migration
  def change
    create_table :work_orders do |t|
        t.integer 'work_order_number'
        t.string 'project_name'
        t.string 'work_order_type'
        t.string 'UNO_project_manager'
        t.string 'business_owner'
        t.string 'program_office'
        t.date 'due_date'
        t.date 'ULL_start_date'
        t.date 'development_end_date'
        t.date 'close_date'
        t.integer 'estimated_hours'
        t.string 'ULL_contact'
        t.string 'summary'
        t.string 'deliverables'
        t.string 'comments'
        t.string 'attachments'
        t.boolean 'approved', default: false
        t.boolean 'submitted', default: false
    end
  end
end
