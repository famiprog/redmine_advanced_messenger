# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'advanced_messenger/:id/:read_by_users/update_journal_read_by_users', :to => 'advanced_messenger#update_journal_read_by_users'
post 'advanced_messenger/:id/:read_by_users/update_message_read_by_users', :to => 'advanced_messenger#update_message_read_by_users'
get 'advanced_messenger/unread_notifications_count', :to => 'advanced_messenger#unread_notifications_count'
get 'advanced_messenger/read_briefly_notifications_count', :to => 'advanced_messenger#read_briefly_notifications_count'
post 'advanced_messenger/ignore_all_unread_issues_notes', :to => 'advanced_messenger#ignore_all_unread_issues_notes'
post 'advanced_messenger/:issue_id/ignore_all_unread_issues_notes', :to => 'advanced_messenger#ignore_all_unread_issues_notes_for_an_issue'
post 'advanced_messenger/ignore_all_unread_forum_messages', :to => 'advanced_messenger#ignore_all_unread_forum_messages'
post 'advanced_messenger/:topic_id/ignore_all_unread_forum_messages', :to => 'advanced_messenger#ignore_all_unread_forum_messages_for_a_topic'
get 'advanced_messenger/:issue_id/:note_id/mark_not_visible_journals_as_ignored_and_redirect', to: 'advanced_messenger#mark_not_visible_journals_as_ignored_and_redirect'
get 'advanced_messenger/:board_id/:topic_id/:page_number/:unread_message_id/mark_not_visible_messages_as_ignored_and_redirect', to: 'advanced_messenger#mark_not_visible_messages_as_ignored_and_redirect'
get 'advanced_messenger/users_overview', to: 'advanced_messenger#users_overview'
get 'advanced_messenger/user/:id/notifications', to: 'advanced_messenger#user_notifications'