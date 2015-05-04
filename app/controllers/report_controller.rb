class ReportController < ApplicationController
before_filter :require_login

def index
	puts 'check here'
@user = User.find(session[:user_id])
@viewable_users= @user.reporting_gas
end


def projectReport
		puts "********************************Project Report******************************"
   	puts params.inspect
   	if params[:user_id].blank?
   		user_id = session[:user_id]
   	else
   		user_id = params[:user_id].to_i
   	end   		 
   	@user = User.find(user_id)   		   
		timeRowArray = []
		hourTotals = []
		today = params[:today].to_date		
		userTable = @user.time_tables
		view = params[:view]
		dateSections = []
		hourTotals = []
	if view == "weekly"
      startDate = (today.beginning_of_week(start_day = :monday)).to_s
      endDate = (today.end_of_week(start_day = :monday)).to_s
			startDate.to_date.upto(endDate.to_date) do |date|
				dateSections << date
				dayTotal = userTable.getDayTotal(date)
				hourTotals << dayTotal
			end
		end
	
		if view == "monthly"
			startDate = today.beginning_of_month.to_s
			endDate = today.end_of_month.to_s
			date = startDate.to_date
			while date.end_of_week < endDate.to_date
				dateSections << date
				weekTotal= userTable.viewDate(date, date.next_week).getTotal
				hourTotals << weekTotal
				date = date.next_week
			end	
		end
		if view == "yearly"
			startDate = today.beginning_of_year.to_s
			endDate = today.end_of_year.to_s
			date = startDate.to_date
		
			while date.end_of_month <= endDate.to_date
				dateSections << date
				monthTotal = userTable.viewDate(date, date.next_month).getTotal
				hourTotals << monthTotal
				date = date.next_month
			end
		end
		
  
		startTime = standJTime(startDate)
		endTime = standJTime(endDate)

		dateSpan = userTable.viewDate(startDate.to_date, endDate.to_date)
		
		timeInfo = {}
		timeRow = dateSpan.alpha.group_by(&:project_data_id)
		timeRowArchived = dateSpan.alphaArchived.group_by(&:project_data_id)
		timeRow = timeRowArchived.merge(timeRow)

	timeRow.each do |key, value|
		key = key.to_i
		if is_archived(key)
			project = ArchievedProject.where(:project_data_id => key).first
		else
			project = ProjectData.find(key)
		end
		timeInfo[project.name] = []
		puts 'check archive name'
		puts project.name
			for i in 0..(dateSections.length - 1) do
				if view == "weekly"
					hours = userTable.getProjectOnDayTotal(key, dateSections[i])
					total = userTable.getProjectOnWeekTotal(key, dateSections[0])
				
			end
				if view == "monthly"
				hours = userTable.getProjectOnWeekTotal(key, dateSections[i])
				total = userTable.getProjectOnMonthTotal(key, dateSections[0])				
			end
				if view == "yearly"
				hours = userTable.getProjectOnMonthTotal(key, dateSections[i])
				total = userTable.getProjectOnYearTotal(key, dateSections[0])
			end
				timeInfo[project.name] << {projectHours: hours, projectDate: standJTime(dateSections[i]), pid: key}
			end
			timeInfo[project.name] << {projectHours: total}
end

		totalHours = dateSpan.getTotal
		puts "total"
		puts totalHours
		hourTotals << totalHours
    timeRowArray << {dates: dateSections.map(&method(:standJTime))}
    timeRowArray << timeInfo
    timeRowArray << {totals: hourTotals}	
	render :json => timeRowArray.to_json
		
	end	
	
	
	
	def createCustomReport
		timeRowArray = []
		if params[:user_id].blank?
			user_id = session[:user_id]
		else
			user_id = params[:user_id].to_i
		end   		 
   		user = User.find(user_id)   

		startDate = params[:start].to_date
		endDate = params[:end].to_date
		
		userTable = user.time_tables
		dateSpan = userTable.viewDate(startDate, endDate)
	timeRow = dateSpan.alpha.group_by(&:project_data_id)
		timeRowArchived = dateSpan.alphaArchived.group_by(&:project_data_id)
		timeRow = timeRowArchived.merge(timeRow)

	timeRow.each do |key, value|
		key = key.to_i
		if is_archived(key)
			project = ArchievedProject.where(:project_data_id => key).first
		else
			project = ProjectData.find(key)
		end
			hours = dateSpan.getProjectTotal(key)
			timeRowArray << {projectName: project.name, projectHours: hours}
		end

			puts "Time Array"
			puts timeRowArray
		
	render :json => timeRowArray.to_json
	end
	
		def createReportPieChart
		   puts "********************************PIE CHART******************************"
   		   puts params.inspect
		   pieHash = {}      
		   today = params[:today].to_date
		   if !params[:view].nil?
		   	view = params[:view]
		   end
		   else if !params[:end].nil?
		   	startDate = today
		   	endDate = params[:end].to_date
		   end
		   	if view == "weekly"
				startDate = today.beginning_of_week.to_s
				endDate = today.end_of_week.to_s
			end
			if view == "monthly"
				startDate = today.beginning_of_month.to_s
				endDate = today.end_of_month.to_s
			end			
			if view == "yearly"
				startDate = today.beginning_of_year.to_s
				endDate = today.end_of_year.to_s				
			end
      if params[:user_id].blank?
        user_id = session[:user_id]
      else
        user_id = params[:user_id].to_i
      end   		 
   		user = User.find(user_id) 
      dateSpan = user.time_tables.where(:date => startDate.to_date..endDate.to_date)
      pieRow = dateSpan.alpha.group_by(&:project_data_id)
      pieRowArchived = dateSpan.alphaArchived.group_by(&:project_data_id)
      pieRow = pieRowArchived.merge(pieRow)

		unless pieRow.nil?
			pieRow.each do |key, value|
				key = key.to_i
				if is_archived(key)
					project = ArchievedProject.where(:project_data_id => key).first
				else
					project = ProjectData.find(key)
				end				
				pieHash[project.name] = dateSpan.getProjectTotal(key)
			end
		end
			puts pieHash
			render :json => pieHash.to_json
	end
	
	def project_colors
		projectColor = session[:project_colors]
		render :json => projectColor.to_json
	end

  def reminder
    @user = User.find(params[:id])    
    @message = "You haven't submitted previous month report. Please Submit it for review."
    WelcomeMailer.send_mail_from_iphone(@user.email,@message).deliver  
    render :text => "Email sent successfully"
  end

end