class WorkOrderAdminController < ApplicationController
 before_filter :require_login, :except => ["activate_user"]
 before_filter :require_activation, :except => ["activate_user","test_mail"]
 before_filter :require_work_order_admin
 
 
 def index
 	@work_orders = WorkOrder.where(:submitted => true)
    @submitted_work_orders = @work_orders.submitted
    @approved_work_orders = @work_orders.approved
    @resubmit_work_orders = WorkOrder.resubmit
    @rejected_work_orders = @work_orders.rejected
    @cancelled_work_orders = @work_orders.cancelled
    @projects = @approved_work_orders.is_type_project
    @support = @approved_work_orders.is_type_support
    @maintentance = @approved_work_orders.is_type_maintenance
 end
 
def assignment
	@users = User.where(:id != session[:user_id])
 	@work_order = WorkOrder.find(params[:id])
	
end

 def review
 	puts params
 	puts 'review'
 	@work_order = WorkOrder.find(params[:id])
 	@work_orders = WorkOrder.where(:submitted => true)
    @submitted_work_orders = @work_orders.submitted
 	@managers = User.where(:manager => true).alpha
 	@employees = User.where(:role => 'Classified' || 'Unclassified').alpha
 		@internalAcct = {};
	InternalProjectAcctNumber.all.each do |i|
		@internalAcct[i.id] = i.acct_number
	end
 	@gas = User.where(:role => 'GA').alpha
 end
 
 def approve
 	data = {}
 	@work_order = WorkOrder.find(params[:id])
 	@work_order.approved = true
	if @work_order.save
  		data[:success]= true
  		render :json => data.to_json
  	else
  		data[:success] = false
  		render :json => data.to_json
  	end   		
 end
 
 def work_order_tracking

 	@statusSelect = [['Assign Status', 'blank'], ['On Hold', 'hold'], ['Complete', 'complete'], ['In Progress', 'progress'], ['Canceled', 'cancel']]
end
 	
 def get_WO_data
 
	today = params[:today].to_date
	work_orders = WorkOrder.approved_all_users
	@employeeTotals = {}
	hourTotals = {}
	view = params[:view]
	
	grandTotal = 0
	overallPrevWeeklyTotal = 0
	estHourTotal=0
	@pGT = 0
	@sGT = 0
	@mGT = 0
	@aGT = 0

	if view != 'yearly'

	work_orders.each do |w|
		a = w.actual_work_order
		pid = a.project_data_id.to_i
		if is_archived(pid)
			archived = true
			project = ArchievedProject.where(:project_data_id => pid).first
		else		
			archived = false
			project = w.project_data
		end
		if view == "weekly"		
			
			startDate = today.beginning_of_week
			timeTables = project.time_tables.where(:date => (startDate - 7.days)..(startDate + 7.days))
			if !(timeTables.blank? && archived)
			weeklyHours = timeTables.getProjectOnWeekTotal(pid, startDate)
				wo = {}
				wo[:work_order_number] = w.work_order_number
				wo[:wid] = w.id
				wo[:work_order_type] = w.work_order_type
				if project.name != w.project_name
					wo[:project_name] = project.name + ' (' + w.project_name + ')'
				else
					wo[:project_name] = project.name
				end
				wo[:wo_status] = a.work_order_status
				wo[:work_status] = a.work_progress_status
				wo[:program_office] = w.program_office
				wo[:project_descript] = a.project_description
				wo[:start_date]= a.start_date
				wo[:end_date] = a.end_date
				wo[:est_hours] = a.estimated_hours
				wo[:hours_worked] = weeklyHours
				wo[:pManager] = w.UNO_project_manager
				wo[:employees] = []
				project.assigned_projects.each do |ap|
					user = user_discover(ap.user_id)
					wo[:employees] << user.last_name
				end
				startDate = today.beginning_of_week - 7.days
				lastWeekTotal = timeTables.getProjectOnWeekTotal(pid, startDate)
				wo[:prev_week] = lastWeekTotal
				
				grandTotal += weeklyHours
				overallPrevWeeklyTotal += lastWeekTotal
				(!a.estimated_hours.nil?)? (estHourTotal += a.estimated_hours) : (estHourTotal += 0)
				
				hourTotals[w.id] = wo
				end


		elsif view == "monthly" || view == "quarterly"
			if !project.time_tables.blank?
				user_data = project.time_tables.group_by{|g| g.user_id}
				user_data.each do |key, value|
					user_id = key.to_i
					user = user_discover(user_id)
					a = w.actual_work_order
					if w.work_order_type != 'admin'
						hours = get_user_total(user, w.id, view, today)
						if hours != 0
						if @employeeTotals[user.last_name].nil?
							@employeeTotals[user.last_name] = []
						end
						wo= {}
					wo[:work_order_number] = w.work_order_number
					wo[:wid] = w.id
					wo[:work_order_type] = w.work_order_type
					wo[:project_name] = w.project_name
					wo[:wo_status] = a.work_order_status
					wo[:work_status] = a.work_progress_status
					wo[:business] = w.business_owner
					wo[:program_office] = w.program_office
					wo[:hours_worked] = hours
					@employeeTotals[user.last_name] << wo
					
					if w.work_order_type == 'project'
						@pGT += hours
					elsif w.work_order_type == 'support'
						@sGT += hours
					elsif w.work_order_type == 'maintenance'
						@mGT += hours
					end
					
					grandTotal += hours
				end
				end
				end
			end
		
		
		
		
		
	
	end
	end
	
	elsif view == "yearly"
	
	 	@work_orders = WorkOrder.where(:approved => true)
    	@project = @work_orders.is_type_project
    	@support = @work_orders.is_type_support
    	@maintenance = @work_orders.is_type_maintenance
    	@admin = @work_orders.is_type_admin
		startDate = today.beginning_of_year
		endDate = today.next_year.beginning_of_year
		count = 1
		
		grandTotal = 0
		projectGrandTotal =0
		supportGrandTotal =0
		maintGrandTotal =0
		adminGrandTotal =0
		
 		while startDate < endDate			
 		puts 'check quarterly dates'
		puts startDate
		puts endDate
		puts count
		
 			if !@project.nil?
 				hours = getWOTotal(@project, startDate, "quarterly")
 				hourTotals['q' + count.to_s + 'Project'] = hours
 				grandTotal += hours
 				projectGrandTotal += hours
 	 		else 
 	 			hourTotals['q' + count.to_s + 'Project'] = 0
 	 		end
 	 		
 	 		if !@support.nil?
 	 			hours = getWOTotal(@support, startDate, "quarterly")
 	 			hourTotals['q' + count.to_s + 'Support'] = hours
 	 			grandTotal += hours
 	 			supportGrandTotal += hours
 			else 
 	 			hourTotals['q' + count.to_s + 'Support'] = 0
 	 		end
 			if !@maintenance.nil?
 				hours = getWOTotal(@maintenance, startDate, "quarterly")
 				hourTotals['q' + count.to_s + 'Maintenance']= hours
 				grandTotal += hours
 				maintGrandTotal += hours
 			else 
 				puts 'main h'

 	 			hourTotals['q' + count.to_s + 'Maintenance'] = 0
 	 		end
 			
 			if !@admin.nil?
 				hours = getWOTotal(@admin, startDate, "quarterly")
 				hourTotals['q' + count.to_s + 'Admin']= hours
 				grandTotal += hours
 				adminGrandTotal += hours
 			else 
 	 			hourTotals['q' + count.to_s + 'Admin'] = 0
 	 		end
			startDate = startDate.next_quarter
			count += 1
			end
	end

	
	if view == "weekly"
		hourTotals[:grandTotal] = grandTotal
		hourTotals[:prevWeekTotal] = overallPrevWeeklyTotal
		hourTotals[:estHourTotal] = estHourTotal
		render :json => hourTotals.to_json  
	elsif view =="yearly" 	
	hourTotals[:grandTotal] = grandTotal
	hourTotals [:pGT] = projectGrandTotal
	hourTotals [:sGT] = supportGrandTotal
	hourTotals [:mGT] = maintGrandTotal
	hourTotals [:aGT] = adminGrandTotal
	render :json => hourTotals.to_json  	
	elsif view="monthly" || view=="quarterly"
			@employeeTotals[:grandTotal] = grandTotal
			@employeeTotals[:pGT] = @pGT
			@employeeTotals[:sGT] = @sGT
			@employeeTotals[:mGT] = @mGT
			@employeeTotals[:aGT] = @aGT
			render :json => @employeeTotals.to_json 
	end

 
 end
 
 def get_admin_data
 	data = {}
 	today = params[:today].to_date
 	view = params[:view]
 	@work_orders = WorkOrder.where(:work_order_type => 'admin', :approved => true)
 	grandTotal = 0
 	@work_orders.each do |w|
		a = w.actual_work_order
		pid = a.project_data_id.to_i
 		if is_archived(pid.to_i)
 			project = ArchievedProject.where(:project_data_id => pid)
 		else
 			project = w.project_data
 		end		
 		aps = project.assigned_projects
 		aps.each do |a|
 			u = user_discover(a.user_id)
 			if view == 'weekly'
 				total = u.time_tables.getProjectOnWeekTotal(pid, today.beginning_of_week)
 			elsif view == 'monthly'
 			 	total = u.time_tables.getProjectOnMonthTotal(pid, today.beginning_of_month)
 			elsif view == 'quarterly'
  				total = u.time_tables.getProjectOnQuarterTotal(pid, today.beginning_of_quarter)
 			elsif view == 'yearly'
  				total = u.time_tables.getProjectOnYearTotal(pid, today.beginning_of_year)
			end
			if total != 0
 			 	data[u.last_name] = [project.name, total]
 			 	grandTotal += total
 			 end
		end
	end
	
	data[:grandTotal] = grandTotal
	
	render :json => data.to_json
 end

 
 def save_awo_edits
 	puts params
 	data = {}
 	view = params[:view]
 	work_order = WorkOrder.find(params[:wID])
 	a = work_order.actual_work_order
 	if view == "weekly"
 	a.project_description = params[:projectDescript]
 	a.start_date = params[:startDate].to_date
 	a.end_date = params[:endDate].to_date
 	a.estimated_hours = params[:estHours]
 	end
 	a.work_order_status = params[:woStatus]
 	a.work_progress_status = params[:workStatus]

	a.save
	render :json => data.to_json

 end
 
 def get_office_percents
 	puts params
 	puts 'updated?'
 	data = {}
	startDate = params[:today].to_date
	view = params[:view]
	work_orders = WorkOrder.approved_all_users
	medicaidWO = work_orders.is_medicaid
	osWO = work_orders.is_os
	ophWO = work_orders.is_oph
	obhWO = work_orders.is_obh
	oaasWO = work_orders.is_oaas
	ocddWO = work_orders.is_ocdd
	
	woTotal = 0
	work_orders.each do |w|
		a = w.actual_work_order
		pid = a.project_data_id.to_i
		 		puts 'debug 0'	

 		if is_archived(pid)
 			project = ArchievedProject.where(:project_data_id => pid).first
 		else
 			project = w.project_data
 		end	
 		puts 'debug 1'	
		if !project.nil?
	 		puts 'debug 2'	
		if view == "monthly"
			date = startDate.beginning_of_month
			if !project.time_tables.nil?
				woTotal += project.time_tables.getProjectOnMonthTotal(pid, date)
			end
		elsif view == "quarterly"
			date = startDate.beginning_of_quarter
			if !project.time_tables.nil?
				woTotal += project.time_tables.getProjectOnQuarterTotal(pid, date)
			end
		elsif view == "yearly"
			date = startDate.beginning_of_year
			puts 'check yearly office'
			if !project.time_tables.nil?
				woTotal += project.time_tables.getProjectOnYearTotal(pid, date)
			end
			puts 'check woTotal'
		end
		end
	end
	woTotal = woTotal.to_f
	if woTotal != 0
		data[:os] = (getWOTotal(osWO, startDate, view).to_f / woTotal) * 100 
		data[:medicaid] = (getWOTotal(medicaidWO, startDate, view).to_f / woTotal) * 100
		data[:oph] = (getWOTotal(ophWO, startDate, view).to_f / woTotal) * 100
		data[:obh] = (getWOTotal(obhWO, startDate, view).to_f / woTotal) * 100
		data[:oaas] = (getWOTotal(oaasWO, startDate, view).to_f / woTotal) * 100
		data[:ocdd] = (getWOTotal(ocddWO, startDate, view).to_f / woTotal) * 100	
		puts 'check office data'
		puts data
	else 
		data[:allZero]= true
	end
	
	render :json => data.to_json
 
 end
 
 def getWOTotal(work_order_coll, date, view)
 	
 	wTotal = 0
 	work_order_coll.each do |w|
			a = w.actual_work_order
			pid = a.project_data_id.to_i
 			if is_archived(pid.to_i)
 				project = ArchievedProject.where(:project_data_id => pid).first
 			else
 				project = w.project_data
 			end		
 		if view =="quarterly"
 			startDate = date.beginning_of_quarter
 			 if !project.nil?
 			if !project.time_tables.nil?
 				wTotal += project.time_tables.getProjectOnQuarterTotal(pid, startDate)
 			end
 			end
 	end
 	if view == "monthly"
 		startDate = date.beginning_of_month
 		if !project.nil?
		if !project.time_tables.nil?
			wTotal += project.time_tables.getProjectOnMonthTotal(pid, startDate)
		end
		end
	end
	if view == "yearly"
 		startDate = date.beginning_of_year
 		if !project.nil?
		if !project.time_tables.nil?
			wTotal += project.time_tables.getProjectOnYearTotal(pid, startDate)
		end
		end
	end
	
	
	end
	return wTotal

 end
 
 def process_report
  	@work_order = WorkOrder.find(params[:wid])

 	approved = params[:approved]
 	
 	if approved == 'true'
 		puts 'check1'
 	 	#Work Order Request has been approved
		@work_order.approved = true
 		@work_order.save
 #Once account numbers are being updated every 15, this will match the project by account number
 		
 		@project = ProjectData.new

 		
		@project.project_type = 'wo'
		@project.name = @work_order.project_name
		descript = params[:descript]
		if !descript.blank?
			@project.description = descript
		end
		
 		if params[:acct_number] == 'Please Select'
 			@acct = ''
 	  		@project.project_id = @acct
 	  		@project.save
 		else
  			@acct = Project.where(:acct_number => params[:acct_number])
  			if @acct.blank? #Then the acct_number is Internal
  				@project.save
  				ip = InternalProjectAcctNumber.new
  				ip.project_data_id = @project.id
  				ip.acct_number = params[:acct_number]
  				ip.save
  			else #Acct Number is an official DHH Account
  			 	@project.project_id = @acct.first.id
  			 	@project.save
  			 end
 		end
		
 		@actual_work_order = ActualWorkOrder.new
 	   @actual_work_order.work_order_id = @work_order.id
 	   @actual_work_order.project_data_id = @project.id 	   
 	   @actual_work_order.estimated_hours = @work_order.estimated_hours
 	   @actual_work_order.start_date = @work_order.ULL_start_date
 	   @actual_work_order.end_date = @work_order.development_end_date
 	   @actual_work_order.project_description = params[:projectDescript]
 	   @actual_work_order.work_order_status = params[:woStatus]
 	   @actual_work_order.work_progress_status = params[:workStatus]
 	   
	   @actual_work_order.save
 		
 		if !params[:project_managers].blank?
 			managers = params[:project_managers].split(",").map(&:to_i)
 			managers.each do |p|
 				@project_manager= ProjectManager.new
 				@project_manager.user_id = p
 				@project_manager.project_data_id = @project.id
 				@project_manager.save

 			end
 		end
 		
 		if !params[:assigned_employees].blank?
 			employees = params[:assigned_employees].split(",").map(&:to_i)
			employees.each do |a|
 		 		@assigned_project = AssignedProject.new
 				@assigned_project.project_data_id = @project.id
 				@assigned_project.user_id = a
 				@assigned_project.save
 			end
 		end 
 		
 		if !params[:gas].blank?
 			gas = params[:gas].split(",").map(&:to_i)
 			gas.each do |p|
 		 		@assigned_project = AssignedProject.new
 				@assigned_project.project_data_id = @project.id
 				@assigned_project.user_id = p
 				@assigned_project.save
 			end
 		end

 		
 		


	   
	   (!params[:includePMList].blank?) ? includePMList = true : includePMList = false
	   (!params[:includeEMList].blank?) ? includeEMList = true : includeEMList = false
	   (!params[:wmMessage].blank?) ? wmMessage = params[:wmMessage] : wmMessage = false	   	
	   (!params[:pmMessage].blank?) ? pmMessage = params[:pmMessage] : pmMessage = false
	   (!params[:emMessage].blank?) ? emMessage = params[:emMessage] : emMessage = false

		if !wmMessage.blank?
 			@feedback = WorkOrderFeedback.new
 			@feedback.work_order_id = @work_order.id
 			@feedback.admin_id = session[:user_id]
 			@feedback.feedback = wmMessage
 			@feedback.save
 		end
		
	   
	   @work_order.work_order_clients.each do |c|
	   	client = User.find(c.user_id)
	   	WelcomeMailer.WO_request_response(client, @work_order, wmMessage, includePMList).deliver
	   end
	   
	   if !managers.blank?
	   managers.each do |m|
	   	WelcomeMailer.project_manager_assignment(User.find(m), @work_order, pmMessage).deliver
	   end
	   end
	   employee_message = params[:messageE]
	   if !employees.blank?
	   employees.each do |e|
	   	WelcomeMailer.employee_assignment(User.find(e), @work_order, emMessage, includeEMList).deliver
	   end
	   end
	  if !gas.blank?
	   gas.each do |e|
	   	WelcomeMailer.employee_assignment(User.find(e), @work_order, emMessage, includeEMList).deliver
	   end
	   end
	   
 	elsif approved == 'false'
 	 puts 'check2'

 	#Work Order Request has been rejected with feedback

 		@work_order.approved = false
 		@work_order.submitted = nil
 		@work_order.save
 		
 		(!params[:wmMessage].blank?) ? wmMessage = params[:wmMessage] : wmMessage = false	   	
 		 
 		if !wmMessage.blank?
 			@work_order_feedback = WorkOrderFeedback.new
 			@work_order_feedback.work_order_id = @work_order.id
 			@work_order_feedback.feedback = wmMessage
 			@work_order_feedback.admin_id = session[:user_id]
 			@work_order_feedback.save
 		end
 		
 		@work_order.work_order_clients.each do |c|
 			WelcomeMailer.WO_request_response(User.find(c.user_id), @work_order, wmMessage, false).deliver
 		end


 		
 	elsif approved == 'pending'
 	 		puts 'check3'

 	#Work Order Request has been taken back to pending with feedback
 		@work_order.submitted = false
 		@work_order.approved = nil
 		@work_order.save

 		(!params[:wmMessage].blank?) ? wmMessage = params[:wmMessage] : wmMessage = false	
 		if !wmMessage.blank?
 		@work_order_feedback = WorkOrderFeedback.new
 		@work_order_feedback.work_order_id = @work_order.id
 		@work_order_feedback.feedback = wmMessage
 		@work_order_feedback.admin_id = session[:user_id]
 		@work_order_feedback.save
 		end
 		@work_order.work_order_clients.each do |c|
 			WelcomeMailer.WO_request_response(User.find(c.user_id), @work_order, wmMessage, false).deliver
 		end
 	end
 	
 	render :js => "window.location = '/work_order_admin'"


 	
 end
 

 def weeklyCSV    
    date = params[:date].to_date
    hourTotals = get_WO_data_inclusive('weekly', date)
    @actual_work_orders = ActualWorkOrder.all  
    employees= User.where(:client => false).alpha
    work_orders_csv = CSV.generate do |csv|        
      
      firstRow = ["Work Order ID", "Project Description", "Program Office", "Project Manager", "Start Date", "End Date", "WO Status", "Work Status", "Est Hours", "Actual Hours", "Prior week"]
      employees.each do |e|
      	firstRow << e.first_name
      end
       csv << firstRow
       totalThisWeek = 0
       totalLastWeek = 0
       totalEstHours = 0
       @actual_work_orders.each do |a|         
			w = a.work_order
			pid = a.project_data_id.to_i
 			if is_archived(pid.to_i)
 				project = ArchievedProject.where(:project_data_id => pid).first
 			else
 				project = w.project_data
 			end		
          	   ap = project.assigned_projects
          	   users = []
          	   ap.each do |aa|
          	   	users << aa.user_id
          	   end
          	  if !hourTotals[w.id].blank?
              infoRow = [w.work_order_number, a.project_description, w.program_office, w.UNO_project_manager, a.start_date, a.end_date, a.work_order_status,
              		(a.work_progress_status=='progress')? 'in progress': a.work_progress_status, a.estimated_hours, hourTotals[w.id][0], hourTotals[w.id][1]]  
             totalThisWeek =  totalThisWeek + hourTotals[w.id][0]
             totalLastWeek = totalLastWeek + hourTotals[w.id][1]
             if !a.estimated_hours.nil?
            	 totalEstHours = totalEstHours + a.estimated_hours
            end
            employees.each do |e|
            		if users.include? e.id
            			infoRow << 'X'
            		else
            			infoRow << ' '
            		end
              end
              
              csv << infoRow
              end	
              	
          end
       csv << []
       csv << ['Grand Total EstHours', totalEstHours]
       csv << ['Grand Total This Week', totalThisWeek]
       csv << ['Grand Total Prior Week', totalLastWeek]
    end
    customName = date.to_s + ':  Report.csv'
	send_data work_orders_csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => customName
  end
  
  def monthly_quarterly_CSV 
  	puts params
  	csv_type = params[:csv_type]   
    date = params[:date].to_date
    hourTotals = get_WO_data_inclusive(csv_type, date)

    if csv_type == 'quarterly'   
    	startDate = date.beginning_of_quarter
    	endDate = date.end_of_quarter
    	customName = 'QReport: ' +startDate.to_s + '.csv'
    else
        startDate = date.beginning_of_month
    	endDate = date.end_of_month
    	customName = 'Monthly Report: ' + startDate.to_s + '.csv'
    end

    officePercents = get_office_percents_inclusive(date, csv_type)
    work_orders_csv = CSV.generate do |csv| 
    	csv << ["Start Date: ", startDate]
    	csv << ["End Date: ", endDate]
      	csv << [ ]
      	csv << [ "Work Order ID", "Project Name", "WO Status", "Current Status", "Business Owner", "Program Office", "ULL CBIT Resource", "Hours Worked"]
       	grand_total = 0
       	hourTotals.each do |wo_type, employees|
      		csv << [ ]
      		csv << [wo_type.to_s.capitalize]
      		csv << []
      		type_total = 0
      		employees.each do |key, v|
      			v.each do |value|
      				w = WorkOrder.find(value[:wid].to_i);
      				a = w.actual_work_order;
        			csv << [w.work_order_number, w.project_name, a.work_order_status, (a.work_progress_status=='progress')? 'in progress': a.work_progress_status, w.business_owner, w.program_office, key, value[:hours_worked]]
    				type_total = value[:hours_worked] + type_total
    			end
    		end
    	grand_total = grand_total + type_total
    	csv << ['Total', type_total] 
    end
    
    csv << []
    csv <<['Grand Total:', grand_total]
    
      csv << [ ]
      csv << ['Office Distributions']
      officePercents.each do |key, value|
      	puts 'officepercents yo'
      	puts key
      	puts value
       csv << [key, value.round.to_s + '%']
       
      end
    end
    
	send_data work_orders_csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => customName
  end
  
def yearlyCSV  
    @approved_work_orders = WorkOrder.approved_all_users

    @projects = @approved_work_orders.is_type_project
    @support = @approved_work_orders.is_type_support
    @maintentance = @approved_work_orders.is_type_maintenance
	@admin = @approved_work_orders.is_type_admin
	
    date = params[:date].to_date
    hourTotals = get_WO_data_inclusive('yearly', date)
    @actual_work_orders = ActualWorkOrder.all  
    officePercents = get_office_percents_inclusive(date, 'yearly')
    work_orders_csv = CSV.generate do |csv|  
    	csv << ['Start Date', date.beginning_of_year]
    	csv << ['End Date', date.end_of_quarter]
    	csv << []
    	
    	project = []
    	support = []
    	maintenance = []
    	admin = []
    	
    	count = 0
    	hourTotals.each do |key, value|
    	if key.end_with?('Project') 
    		project << [key, value] 
    	elsif key.end_with?('Support')
    			support << [key, value] 
    	elsif key.end_with?('Maintenance')
    		maintenance << [key, value] 
    	elsif key.end_with?('Admin')
    		admin << [key, value] 
    	end
    	
    end
    	project.each do |p|
    		csv << [p[0], p[1]]
    	end
    	csv << []
    	support.each do |p|
    		csv << [p[0], p[1]]
    	end
    	csv << []
    	maintenance.each do |p|
    		csv << [p[0], p[1]]
    	end
    	csv << []	
    	admin.each do |p|
    		csv << [p[0], p[1]]
    	end
    	
           csv << [ ]
      csv << ['Office Distributions']
      officePercents.each do |key, value|
       csv << [key, value.round.to_s + '%']
       
      end
end
    	
    customName = date.year.to_s + ': Yearly Report.csv'
	send_data work_orders_csv, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment", :filename => customName
  end
 
def get_WO_data_inclusive(view, today)
 
 	work_orders = WorkOrder.approved_all_users
	
	employeeTotals = {}
	hourTotals = {}
	
	if view == 'weekly'
		hourTotals = get_work_order_hours(work_orders, view, today)
		puts 'weekly hours'
		puts hourTotals
		return hourTotals
	elsif view == 'monthly' || view =='quarterly'
		employeeTotals[:project] = get_work_order_hours(work_orders.is_type_project.alpha, view, today)
		employeeTotals[:maintenance] = get_work_order_hours(work_orders.is_type_maintenance.alpha, view, today)
		employeeTotals[:support] = get_work_order_hours(work_orders.is_type_support.alpha, view, today)
		employeeTotals[:admin] = get_work_order_hours(work_orders.is_type_admin.alpha, view, today)
		if employeeTotals.count > 0
			return employeeTotals
		else
			data = {}
			data[:empty]=true
			render :json => data.to_json
		end
	elsif view == "yearly"
	
    	project = work_orders.is_type_project
    	support = work_orders.is_type_support
    	maintenance = work_orders.is_type_maintenance
    	admin = work_orders.is_type_admin
    	
		startDate = today.beginning_of_year
		count = 1
 			while startDate <= Date.today
 			if !project.nil?
 				hourTotals['q' + count.to_s + 'Project'] = getWOTotal(project, startDate, "quarterly")
			else
 				hourTotals['q' + count.to_s + 'Project']= 0
 			end
 	 		if !support.nil?
 	 			hourTotals['q' + count.to_s + 'Support'] = getWOTotal(support, startDate, "quarterly")
			else
 				hourTotals['q' + count.to_s + 'Support']= 0
 			end

 			if !maintenance.nil?
 				hourTotals['q' + count.to_s + 'Maintenance']= getWOTotal(maintenance, startDate, "quarterly")
 			else
 				hourTotals['q' + count.to_s + 'Maintenance']= 0
 			end

 			if !admin.nil?
 				hourTotals['q' + count.to_s + 'Admin']= getWOTotal(admin, startDate, "quarterly")
 			else
 				hourTotals['q' + count.to_s + 'Admin']= 0
 			end

 			if !work_orders.nil?
 				hourTotals['q' + count.to_s + 'Total']= getWOTotal(work_orders, startDate, "quarterly")
			else
 				hourTotals['q' + count.to_s + 'Total']= 0
 			end

			startDate = startDate.next_quarter
				count += 1
			end
		return hourTotals
	end


end

def get_work_order_hours(wo_coll, view, today)
	employeeTotals = {}
	hourTotals = {}
	wo_coll.each do |w|		
		a = w.actual_work_order
		pid = a.project_data_id.to_i
 	if is_archived(pid.to_i)
 		project = ArchievedProject.where(:project_data_id => pid).first
 	else
 		project = w.project_data
 	end		
			if view == "weekly"
				if !project.time_tables.blank?
					timeTables = project.time_tables
					startDate = today.beginning_of_week
					hourTotals[w.id] = timeTables.getProjectOnWeekTotal(pid, startDate)
					startDate = today.beginning_of_week - 7.days
					lastWeekTotal = timeTables.getProjectOnWeekTotal(pid, startDate)
					hourTotals[w.id] = [hourTotals[w.id], lastWeekTotal]
				else
					hourTotals[w.id] = [0.0, 0.0]
				end

			elsif view == "monthly" || view == "quarterly"
		
				p = project
				user_data = p.time_tables.group_by{|g| g.user_id}
				user_data.each do |key, value|
					user = user_discover(key.to_i)
					hours = get_user_total(user, w.id, view, today)
					if hours != 0
						if employeeTotals[user.last_name].blank?
							employeeTotals[user.last_name] = []
						end
					wo= {}
					wo[:work_order_number] = w.work_order_number
					wo[:wid] = w.id
					wo[:work_order_type] = w.work_order_type
					wo[:project_name] = w.project_name
					wo[:wo_status] = a.work_order_status
					wo[:work_status] = a.work_progress_status
					wo[:business] = w.business_owner
					wo[:program_office] = w.program_office
					wo[:hours_worked] = hours
					employeeTotals[user.last_name] << wo
				end
			end
		end
		
		end
		
		
		
	
	if view == "weekly"
		return hourTotals
	else
		return employeeTotals
	end

end

 def get_office_percents_inclusive(today, view)
 	puts params
 	data = {}
	startDate = today.to_date
	work_orders = WorkOrder.approved_all_users
	medicaidWO = work_orders.is_medicaid
	osWO = work_orders.is_os
	ophWO = work_orders.is_oph
	obhWO = work_orders.is_obh
	oaasWO = work_orders.is_oaas
	ocddWO = work_orders.is_ocdd
	
	woTotal = 0
	work_orders.each do |w|
		a = w.actual_work_order
		pid = a.project_data_id.to_i
		if is_archived(pid.to_i)
		 		project = ArchievedProject.where(:project_data_id => pid).first
		 else
			project = w.project_data
		 end
		 if !project.nil?
		if view=="monthly"
		date = startDate.beginning_of_month
		if !project.time_tables.nil?
			woTotal += project.time_tables.getProjectOnMonthTotal(pid, date)
		end
		elsif view=="quarterly"
		date = startDate.beginning_of_quarter
		if !project.time_tables.nil?
			woTotal += project.time_tables.getProjectOnQuarterTotal(pid, date)
		end
		elsif view == "yearly"
		date = startDate.beginning_of_year
		
		if !project.time_tables.nil?
			woTotal += project.time_tables.getProjectOnYearTotal(pid, date)
		end
		
		end
		end
	end
	woTotal = woTotal.to_f
	if woTotal != 0
		data[:os] = (getWOTotal(osWO, startDate, view).to_f / woTotal) * 100 
		data[:medicaid] = (getWOTotal(medicaidWO, startDate, view).to_f / woTotal) * 100
		data[:oph] = (getWOTotal(ophWO, startDate, view).to_f / woTotal) * 100
		data[:obh] = (getWOTotal(obhWO, startDate, view).to_f / woTotal) * 100
		data[:oaas] = (getWOTotal(oaasWO, startDate, view).to_f / woTotal) * 100
		data[:ocdd] = (getWOTotal(ocddWO, startDate, view).to_f / woTotal) * 100	
		puts 'check office data'
		puts data
	else 
		data[:allZero]= true
	end
	
	return data
 end 

   def get_user_total(user, wid, view, startDate) 
 	work_order = WorkOrder.find(wid)
 	actual = work_order.actual_work_order
 	pid = actual.project_data_id.to_i
 	time_tables = user.time_tables
 	if is_archived(pid.to_i)
 		project = ArchievedProject.where(:project_data_id => pid.to_i)
 	else
 		project = work_order.project_data
 	end
 	if view == "monthly"
 		return time_tables.getProjectOnMonthTotal(pid.to_i, startDate.beginning_of_month)
 	
 	else 
		return time_tables.getProjectOnQuarterTotal(pid.to_i, startDate.beginning_of_quarter) 		
		
 	end
 	end
  

	
 
end
