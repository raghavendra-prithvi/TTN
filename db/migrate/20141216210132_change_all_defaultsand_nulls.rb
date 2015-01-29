class ChangeAllDefaultsandNulls < ActiveRecord::Migration
  def change
	  ArchievedProject.columns.each do |column|
			change_column_null :archieved_projects, column.name, false
		end
	
		AssignedProject.columns.each do |column|
			change_column_null :assigned_projects, column.name, false
		end
		
		Attachment.columns.each do |column|
			if column.name != 'title' && column.name != 'about'
				Attachment.update_all({ column.name => ''}, {column.name => nil})				
				change_column_null :attachments, column.name, false
			end
		end

		CustomRole.columns.each do |column|
			change_column_null :custom_roles, column.name, false
		end

		DisabledUser.columns.each do |column|
			change_column_null :disabled_users, column.name, false
		end

		Identity.columns.each do |column|
			Identity.update_all({ column.name => ''}, {column.name => nil})				
			change_column_null :identities, column.name, false
		end

		InternalProjectAcctNumber.columns.each do |column|
			change_column_null :internal_project_acct_numbers, column.name, false
		end

		ProjectData.columns.each do |column|

			if column.type == 'boolean'
				change_column_default :project_data, column.name, false
			end
			if column.name != "project_id"
				ProjectData.update_all({ column.name => ''}, {column.name => nil})				
				change_column_null :project_data, column.name, false
			end
		end

		ProjectManager.columns.each do |column|
			change_column_null :project_managers, column.name, false
		end

		Reporter.columns.each do |column|
			Reporter.update_all({ column.name => ''}, {column.name => nil})				
			change_column_null :reporters, column.name, false
		end

		SubmittedReport.columns.each do |column|
			if !['approved', 'rejected', 'submitted_to', 'feedback'].include?(column.name)
				change_column_null :submitted_reports, column.name, false
			end
		end

		TimeModifiedReport.columns.each do |column|
			TimeModifiedReport.update_all({ column.name => ''}, {column.name => nil})				
			change_column_null :time_modified_reports, column.name, false
		end

		TimeTable.columns.each do |column|
			TimeTable.update_all({ column.name => ''}, {column.name => nil})				
			change_column_null :time_tables, column.name, false
		end

		UllTeamMember.columns.each do |column|
			change_column_null :ull_team_members, column.name, false
		end

		UserPermission.columns.each do |column|
			change_column_null :user_permissions, column.name, false
		end

		User.columns.each do |column|
			if !["client", "avatars", "country", "signer", "shares", "provider", "reporter", "reported_by", "active", "token", "password_reset_token", "password_reset_sent_at"].include?(column.name)
				User.update_all({ column.name => ''}, {column.name => nil})				
				if column.type == 'boolean'
					change_column_default :users, column.name, false
				end
				change_column_null :users, column.name, false
			end
		end

		WorkOrderClient.columns.each do |column|
			change_column_null :work_order_clients, column.name, false
		end

		WorkOrderFeedback.columns.each do |column|
			change_column_null :work_order_feedbacks, column.name, false
		end



  end
end
