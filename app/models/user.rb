class User < ActiveRecord::Base
  attr_accessible :name, :email,:first_name,:last_name, :country, :password, :password_confirmation, :remember_token,:token, :id  				   
  #has_secure_password
  before_create :add_domain_to_email
  
  has_many :reported_users, through: :reporters, source: :reported
  has_many :time_tables
  has_many :project_datas, :through => :time_tables
  has_many :work_order_clients
  has_many :work_orders, :through => :work_order_clients
  has_many :work_order_feedbacks, :as => :admin_id
  has_many :assigned_projects
  has_many :project_managers
  has_many :user_custom_roles
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }, :if => :not_twitter?


    def not_twitter?
      return false
    end
  
  	 def self.alpha
        order("last_name ASC")
      end
	
    def add_domain_to_email
      email = self.email
      email_array = email.split("@")
      if email_array[1].nil?
        self.email = self.email + "@louisiana.edu"
      end
    end
  
    def self.from_omniauth(auth)
        #find_by_provider_and_uid(auth["provider"], auth["uid"]) || create_with_omniauth(auth)
        email = auth["info"]["email"]
        email_array = email.split("@")
        if email_array[1].nil?
          auth["info"]["email"] = auth["info"]["email"] + "@louisiana.edu"
        end
				puts auth
        find_by_email(auth["info"]["email"]) || create_with_omniauth(auth)
    end

    def self.create_with_omniauth(auth)
      create! do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        user.name = auth["info"]["name"]
        user.first_name = auth["info"]["first_name"]
        user.last_name = auth["info"]["last_name"]
        user.email = auth["info"]["email"]
        user.role = auth["info"]["role"]
        user.reporter = auth["info"]["reporter"]
        user.create_remember_token
      end
    end

    def apply_omniauth(omniauth)
		  authentications.build(:provider => omniauth['provider'],:uid => omniauth['uid'])
    end


    def create_remember_token
        if new_record?
          self.token = SecureRandom.urlsafe_base64
        end
    end
    
    def get_user_roles
    	roles = []
    	if self.manager
    		roles << 'manager'
    	end
    	if self.time_sheet_collaborator
    		roles << 'time_sheet_collaborator'
    	end
    	if self.time_sheet_manager
    		roles << 'time_sheet_manager'
    	end
    	if self.work_order_admin
    		roles << 'work_order_admin'
    	end
    	if self.project_admin
    		roles << 'project_admin'
    	end
    	if self.admin
    		roles << 'admin'
    	end
		return roles
    end
    
    def generate_token(column)
        begin
          self[column] = SecureRandom.urlsafe_base64
        end while User.exists?(column => self[column])
    end  
      
    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      WelcomeMailer.password_reset(self).deliver
    end

	def allow_delete
		#Allow clients to be deleted if not linked to work orders in processing or use
		if self.client
			client_work_orders = self.work_orders
			if !client_work_orders.blank?
				if client_work_orders.submitted.blank? && client_work_orders.approved.blank? && client_work_orders.resubmit.blank? &&
				    client_work_orders.saved.blank?
				    return true
				else
					return false
				end
			else
				return true
			end
		else
		#Allow users to be deleted if not assigned to projects and have never clocked hours
			if (self.time_tables.blank? && self.assigned_projects.blank? && self.project_managers.blank?)
				return true
			else
				return false
			end
		end	
	end
	

	def reporting_gas
		reporting_gas = []
		user_id = self.id
		User.where(:role => 'GA').each do |ga|
			if ga.reporter == user_id
				reporting_gas << ga
			end
		end
		return reporting_gas
	end
	

	def ga
		self.role == 'GA'
	end


  scope :employees, -> {where role: ['Classified', 'Unclassified']}
  scope :gas, -> {where role: 'GA'}
  scope :unclassified, -> {where role: 'Unclassified'}
  scope :classified, -> {where role: 'Classified'}
  scope :search_by, lambda {|userid| where(:id => userid) }
  end
