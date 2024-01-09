# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'advanced_messenger/:id/:read_by_users/update_journal_read_by_users', :to => 'advanced_messenger#update_journal_read_by_users'
post 'advanced_messenger/:id/:read_by_users/update_message_read_by_users', :to => 'advanced_messenger#update_message_read_by_users'
get 'advanced_messenger/unread_notifications_count', :to => 'advanced_messenger#unread_notifications_count'
