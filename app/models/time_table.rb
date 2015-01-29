class TimeTable < ActiveRecord::Base
attr_accessible :project_data_id, :user_id, :date, :hours, :created_at, :updated_at

belongs_to :project_data
belongs_to :user

scope :chronological, :order => 'date ASC'


def self.alpha
	joins(:project_data).order("project_data.name ASC")
end

def self.alphaArchived
	joins("JOIN archieved_projects ON archieved_projects.project_data_id = time_tables.project_data_id")

end

def self.viewDate (startDate, endDate)
	where(:date => startDate..endDate)
end

def self.getTotal
	sum('hours')
end

def self.getDayTotal (day)
	where(:date => day).sum('hours')
end


def self.getProjectOnDayTotal (pId, day)  
  if self.where(:date => day, :project_data_id => pId).empty?
    nil
  else
    where(:date => day, :project_data_id => pId).sum('hours')
  end
end

def self.getProjectOnWeekTotal(pId, start)
	where(:date=> start..start.next_week, :project_data_id => pId).sum('hours')
end	

def self.getProjectOnMonthTotal(pId, start)
	where(:date=> start..start.next_month, :project_data_id => pId).sum('hours')
end

def self.getProjectOnQuarterTotal(pId, start)
	where(:date=> start..start.next_quarter, :project_data_id => pId).sum('hours')
end


def self.getProjectOnYearTotal(pId, start)
	where(:date=> start..start.next_year, :project_data_id => pId).sum('hours')
end

def self.getProjectTotal (pId)
	where(:project_data_id => pId).sum('hours')
end






end