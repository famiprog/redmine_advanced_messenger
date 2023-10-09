# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'advanced_messenger/:id/:read_by_users/update_read_by_users', :to => 'advanced_messenger#update_read_by_users'
get 'advanced_messenger/:id/issue_notifications', :to => 'advanced_messenger#issue_notifications'