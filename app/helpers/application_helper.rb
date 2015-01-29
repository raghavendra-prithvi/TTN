module ApplicationHelper

  # Returns the full title on a per-page basis in the browser
  def full_title(page_title)
    base_title = "MusicFeed"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
    # Returns the title on a per-page basis on the page
  def infull_title(inpage_title)
    if !inpage_title.empty?
      "#{inpage_title}"
    end
  end
  
  def flash_class(level)
    case level
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-danger"
        when :alert then "alert alert-warning"
    end
  end

def is_active?(link_path)
  current_page?(link_path) ? "active" : ""
 end

def reload_flash
  page.replace "flash_messages", :partial => 'layouts/flash'
end

## if show_submit_report? || submit_report_blink?


	def submit_report_blink?
		puts 'blink last'
		today = Date.today
		#today = "2014-07-31".to_date
		puts today
		lastDay = today.beginning_of_month
		srLastMonth = SubmittedReport.where(:report_for => session[:user_id], :month => Date::MONTHNAMES[today.last_month.month])
		if (srLastMonth.blank? || srLastMonth[0].rejected) && (today >= lastDay) && !new_employee_month?(session[:user_id])
			puts 'true'
			return true
		else
			puts 'false'
			return false
		end
	end
	
	def show_submit_report?
		puts 'show last'
		#### Edit today for testing
		today = Date.today
		#today = "2014-07-31".to_date

		srLastMonth = SubmittedReport.where(:report_for => session[:user_id], :month => Date::MONTHNAMES[today.last_month.month])
		firstDay = today.beginning_of_month
		puts firstDay
		lastDay = firstDay + 7.days
		if User.find(session[:user_id]).role == 'GA'
		if ((today >= firstDay && today <= lastDay) && srLastMonth.blank?) || submit_report_blink?
			puts 'true'
			return true
		end
		else
			puts 'false'
			return false
		end
	end
	
		
	def new_employee_month?(uid)
		user = User.find(uid)
		createdDate = user.created_at
		today = Date.today
		puts 'check creation'
		puts createdDate
		puts today
		if today.month != createdDate.month || today.year != createdDate.year
			return false
		else
			return true
		end
	end

	def report_approved?
		puts 'approve last'
		today = Date.today
		currentMonth = Date.today.month
		puts currentMonth
		sr = SubmittedReport.where(:report_for => session[:user_id], :month => Date::MONTHNAMES[currentMonth])
		if !sr.blank?
			if sr[0].approved
				puts 'true'
				return true
			else
				puts 'false'
				return false
			end
		else
			puts 'false'
			return false
		end
	end
	
	def show_edit_submit_WO(work_order)
		work_orders = WorkOrder.all
		user = User.find(session[:user_id])
		if user.work_order_admin
			return false
		else
			if work_orders.saved.include?(work_order) || work_orders.resubmit.include?(work_order) || work_orders.approved.include?(work_order) || work_orders.submitted.include?(work_order)
				return true
			else
				return false
			end
		end
	end
	
	def show_delete_WO(work_order)
		work_orders= WorkOrder.all
		user=User.find(session[:user_id])
		if user.work_order_admin
			return false
		else
			if work_orders.rejected.include?(work_order) || work_orders.cancelled.include?(work_order) || work_orders.saved.include?(work_order)
				return true
			else
				return false
			end
		end
	end


		

end
