# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'advanced_messenger/:id/:read_by_users/update_journal_read_by_users', :to => 'advanced_messenger#update_journal_read_by_users'
post 'advanced_messenger/:id/:read_by_users/update_message_read_by_users', :to => 'advanced_messenger#update_message_read_by_users'
post 'advanced_messenger/ignore_all_unread_issues_notes', :to => 'advanced_messenger#ignore_all_unread_issues_notes'
post 'advanced_messenger/:issue_id/ignore_all_unread_issues_notes', :to => 'advanced_messenger#ignore_all_unread_issues_notes_for_an_issue'
post 'advanced_messenger/ignore_all_unread_forum_messages', :to => 'advanced_messenger#ignore_all_unread_forum_messages'
post 'advanced_messenger/:topic_id/ignore_all_unread_forum_messages', :to => 'advanced_messenger#ignore_all_unread_forum_messages_for_a_topic'
