module AdvancedMessengerHelper

    def getUnreadNotificationsForIssue(issue)
        unread_notifications_for_current_user = 0;
        unread_notifications_for_others = Hash.new;
        first_unread_notification_index = -1;

        issue.visible_journals_with_index.each do |journal| 
            next if !journal.notes?
            read_by_users = JSON.parse(journal.read_by_users)
            read_by_users.each do |userId, value|
                if read_by_users[userId]["read"] == 0
                    if userId == User.current.id.to_s 
                        unread_notifications_for_current_user += 1
                        if first_unread_notification_index == -1 
                            first_unread_notification_index = journal.indice
                        end
                    else
                        user = User.find(userId)
                        unread_notifications_for_others[userId] = UnreadNotificationsStatus.new(0, (user.firstname.capitalize + " " +  user.lastname.capitalize)) if unread_notifications_for_others[userId] == nil 
                        unread_notifications_for_others[userId].count += 1
                    end
                end
            end
        end
        return [first_unread_notification_index, unread_notifications_for_current_user, unread_notifications_for_others]
    end

    def getUnreadNotificationsForCurrentUserGroupByIssues() 
        unread_notifications = Journal.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%')
        unread_notifications.sort_by{|j| j.issue.id}
        unread_notifications_per_issue = Hash.new

        unread_notifications.each do |journal|
            if unread_notifications_per_issue[journal.issue.id] != nil
                unread_notification_status = unread_notifications_per_issue[journal.issue.id]
            else
                # we set user to nil because is always the current user
                unread_notification_status = UnreadNotificationsStatus.new(0, nil, journal.issue)
                unread_notifications_per_issue[journal.issue.id] = unread_notification_status
            end
            unread_notification_status.count += 1 
        end
        return unread_notifications_per_issue
    end

    def getUnreadNotificationsForCurrentUserCount()
        return Journal.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').count;
    end
end
