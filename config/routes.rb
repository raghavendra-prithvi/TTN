MusicFeedApp::Application.routes.draw do
  get "admin/index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  get '/admin/hoursWorked'
  #Resources
  root 'sessions#new'
  resources :sessions, only: [:new, :create, :destroy]
  resources :users
  resources :work_orders
  resources :attachments
  resources :ull_team_members
  resources :password_resets

  scope "/admin" do
    resources :projects do
      collection do
        get 'assign'
      end
    end
  end
    
  scope "/admin" do
    resources :project_datas do
      collection do
        get 'assign'
      end
    end
  end

    
  resources :project_datas do
    member do
       get 'project_managers'
    end
  end

  #Welcome Controller # Effort Tracker Home
  get 'login', to: 'welcome#index'
  get '/help', to: 'welcome#help'
  get 'welcome/index', to: 'welcome#index'
  get '/load_today_data', to: 'time_sheets#loadToDay'
  post '/saveTimeSheets', to: 'time_sheets#saveTime'
  post '/saveDayTimesheets', to: 'time_sheets#saveDayTime'
  get 'welcome/weekFunc', to: 'time_sheets#weekFunc'
  get '/createPieChart', to: 'time_sheets#createPieChart'
  get '/checkPrevTimeSheets', to: 'time_sheets#checkPrevTimeSheets'
  match '/deleteDayTimesheets', :to => 'time_sheets#deleteDayTimesheets', via: [:get, :post]
  get '/UserGuide', :to => 'time_sheets#user_guide'
  get '/ProjectsPersonnel', :to => 'projects#project_page'


  ######################################################
  ############## Authentication ########################
  match '/auth/:provider/callback' => 'sessions#create' , via: [:get, :post]
  match "/auth/failure" => "sessions#failure", via: [:get, :post]
  get '/signin',  to: 'sessions#new'
  get '/signout', to: 'sessions#destroy'
  get '/signup', to: 'users#new'
  get '/Client', to: 'sessions#new_client'
  get '/renderRoleInfo', to: 'sessions#render_role_info'

  ## Employee User Actions
  get '/monthlyClassifiedReport', to: 'admin#monthlyEmployeeReport'
  get '/registration', to: 'registrations#new'
  get '/view_report', to: 'time_sheets#view_report'
  get '/send_mail', to: 'time_sheets#send_mail'
  get '/activate_user', to: "time_sheets#activate_user"
  get '/time_sheet_reports', to: "time_sheets#time_sheet_reports"
  
  
  
  
    

  
    
    

  #Report Data
    get "/project_colors", to: 'report#project_colors'
    get '/createReportPieChart', to: 'report#createReportPieChart'
    get '/createCustomReport', to: 'report#createCustomReport'
    get '/TimeSummaries', to: 'time_sheets#report'
    get '/projectReport', to: 'report#projectReport'
    get '/sendReportReminder', to: 'report#reminder'
  
  #Report Handling
    get '/send_report', to: "time_sheets#send_report"
    get '/submit_report', to: 'time_sheets#submit_report'
    get '/weeklyTimeView', to: 'time_sheets#weekly_time_view'
    get '/checkPrevWeekHours', to: 'time_sheets#check_prev_week_hours'


  #Work Order Maintence/Handling
    get 'work_orders/index', to: 'work_orders#index'
    get '/work_order_admin', to: 'work_order_admin#index'
    get'/processReport', to: 'work_order_admin#process_report'
    get '/work_order_assignment/:id', to: 'work_order_admin#assignment'
    get '/work_order_review/:id', to: 'work_order_admin#review'
	  get '/work_order_submit', to: 'work_orders#submit'
	  get '/work_order_approve', to: 'work_order_admin#approve'
	  get '/deleteAttachment', to: 'work_orders#delete_attachment'
	  get '/buildAttachment', to: 'work_orders#build_attachment'
	  get '/WorkOrderTracking', to: 'work_order_admin#work_order_tracking'
	  get '/getAttachments', to: 'work_orders#get_attachments'
	  get '/clearAllAttachments', to: 'work_orders#clear_all_attachments'	
	  get '/checkAttachment', to: 'work_orders#check_attachment'
	  post '/dropzone', to: 'work_orders#dropzone'
	  get '/getWOData', to: 'work_order_admin#get_WO_data'
	  get '/getEmails', to: 'work_order_admin#get_emails'
	  get '/saveAWOEdits', to: 'work_order_admin#save_awo_edits'
	  get '/getOfficePercents', to: 'work_order_admin#get_office_percents'
    get "/monthly_quarterly_CSV", to: "work_order_admin#monthly_quarterly_CSV"
    get "/yearlyCSV", to: "work_order_admin#yearlyCSV"
    get "/weeklyCSV", to: "work_order_admin#weeklyCSV"
		get "/get_admin_data", to: "work_order_admin#get_admin_data"
		
		

  #Admin Controls
  get "/admin", to: 'admin#index'
  get "/admin/users", to: 'admin#users'
  post "/updateUser", to: 'admin#updateUser'
  get "/reportingusers", to: "admin#assign_users"
  post "/activateProject", to: "projects#activate"
  post "/deactivateProject", to: "projects#deactivate"
  get "/archived_projects", to: "projects#archived"
  get "/archivedProjectdetails", to: "projects#archivedProjectDetails"
  get '/saveProject', to: 'projects#save_project'
  get '/archiveProject', to: 'projects#archive_project'
  get '/createProject', to: 'projects#create_project'
  get '/editUserPermissions', to: 'admin#edit_permissions'
  get '/usersTable', to: 'admin#users_table'
  get '/get_user_permissions', to: 'admin#get_user_permissions' 
  get '/delete_role', to: 'admin#delete_role'
  get '/edit_custom_role', to: 'admin#edit_custom_role'
  get '/save_new_role', to: 'admin#save_new_role'
  get '/get_custom_role_permissions', to: 'admin#get_custom_role_permissions'
  get '/load_custom_roles', to: 'admin#load_custom_roles'
  get '/get_role_hierarchy', to: 'admin#get_role_hierarchy'
  get '/load_new_role', to: 'admin#load_new_role'
  get '/load_user_info', to: 'admin#load_user_info'
  get '/disable_user', to: 'admin#disable_user'
  get '/enable_user', to: 'admin#enable_user'
  get "/delete_user", to: 'admin#delete_user'
  get '/users_table', to: 'admin#users_table'
  get'/reload_assigned_users', to: 'projects#reload_assigned_users'

  
  #Manager Home : Project Manager
  get "/manager", to: "manager#manager"
  post "/assignProjects", to: "manager#assignProjects"
  post "/removeProjects", to: "manager#removeProjects"
  get '/searchUsers', :to => 'manager#searchUsers'
  get '/getUsersList', :to => 'manager#getUsersList'
  
  #Time Sheet Repoer Manager 
  get '/verify_report', to: 'time_sheets#verify_report'
  get '/approve_report', to: 'time_sheets#approve_report'
  get '/reject_report', to: 'time_sheets#reject_report'
  get "/manageReports", to: "admin#manageReports"
  get "/tsmanageReports", to: "admin#manageReports"
  get "/ts_manager_csvReport", to: "admin#ts_manager_csvReport"
  get '/renderUserData', to: 'admin#render_user_data'
  
  
  #timesheet Managers
  get '/saveModifiedHours', to: "admin#saveModifiedHours"
  post '/saveModifiedHours', to: "admin#saveModifiedHours"
  get '/newReport', to: "admin#newReportEmployee"
  get '/employeeReportUpdated', to: "admin#employeeReportUpdated"
  get '/update_user_lock', to: 'admin#update_user_lock'
  get '/update_all_locks', to: 'admin#update_all_locks'
  get '/update_project_locks', to: 'admin#update_project_locks'
  get '/update_all_project_locks', to: 'admin#update_all_project_locks'
  get '/update_prev_month_all_lock', to: 'admin#update_prev_month_all_lock'
  get '/update_prev_month_user_lock', to: 'admin#update_prev_month_user_lock'
  get '/check_TS_locks', to: 'time_sheets#check_TS_locks'
  #resources :identities  
  match 'active'  => 'sessions#active',  via: :get
  match 'timeout' => 'sessions#timeout', via: :get
  
  
  
  #Version Management
  get '/versionUpdates', to: 'versions#index'
  
  #Exception Handling
  get '404', to: redirect('/')
  
    
    #resources :projects, :path => "admin/projects"
# Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
