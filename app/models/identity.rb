class Identity < OmniAuth::Identity::Models::ActiveRecord
  attr_accessible :email, :first_name,:last_name,:name, :password_digest, :password, :password_confirmation, :role
  validates :password,
                       :confirmation => true,
                       :length => {:within => 6..40},
                       :on => :create
  validates_uniqueness_of :email
  #validates_presence_of :role
#   validate :name_present?
  
#   def name_present?
#     if self.first_name.blank? and self.last_name.blank? 
#       errors.add_to_base("You must enter either first name or last name.")
#     end
#   end
end