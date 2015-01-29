class FixDumbMistakes5 < ActiveRecord::Migration
  def change
	  ArchievedProject.columns.each do |column|
			change_column_null :archieved_projects, column.name, true
		end
	
		AssignedProject.columns.each do |column|
			change_column_null :assigned_projects, column.name, true
		end
		
		Attachment.columns.each do |column|
				change_column_null :attachments, column.name, true
		end

		CustomRole.columns.each do |column|
			change_column_null :custom_roles, column.name, true
		end

		DisabledUser.columns.each do |column|
			change_column_null :disabled_users, column.name, true
		end

		Identity.columns.each do |column|
			change_column_null :identities, column.name, true
		end

		InternalProjectAcctNumber.columns.each do |column|
			change_column_null :internal_project_acct_numbers, column.name, true
		end

		ProjectData.columns.each do |column|

				change_column_default :project_data, column.name, true
		end

		ProjectManager.columns.each do |column|
			change_column_null :project_managers, column.name, true
		end

		Reporter.columns.each do |column|
			change_column_null :reporters, column.name, true
		end

		SubmittedReport.columns.each do |column|
				change_column_null :submitted_reports, column.name, true
		end

		TimeModifiedReport.columns.each do |column|
			change_column_null :time_modified_reports, column.name, true
		end

		TimeTable.columns.each do |column|
			change_column_null :time_tables, column.name, true
		end

		UllTeamMember.columns.each do |column|
			change_column_null :ull_team_members, column.name, true
		end

		UserPermission.columns.each do |column|
			change_column_null :user_permissions, column.name, true
		end

		User.columns.each do |column|
					change_column_default :users, column.name, true
		end

		WorkOrderClient.columns.each do |column|
			change_column_null :work_order_clients, column.name, false
		end

		WorkOrderFeedback.columns.each do |column|
			change_column_null :work_order_feedbacks, column.name, false
		end



  end
end