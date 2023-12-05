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

    def getUsersReadStatus(journal)
        read_by_users = JSON.parse(journal.read_by_users)
        read_statuses = Hash.new
        users = Hash.new
        read_by_users.keys.each_with_index do |user_id, index|
            if (!read_by_users[user_id]["read"]) 
                # no read status for this user i.e. the note is not of interest for him
                next
            end
            user = User.find(user_id)
            user_short = Hash.new
            user_short["firstname"] = user.firstname
            user_short["lastname"] = user.lastname
            user_short["link"] = link_to_user(user)
            users[user_id] = user_short  

            read_by_user = read_by_users[user_id] 
            # For the moment the changing of the read status doesn't have an associated activity so no need to link to the activity page
            #read_by_user["date"] =  l(:label_time_ago, :time => time_tag(read_by_user["date"].to_time).html_safe);
            read_by_user["date"] =  l(:label_time_ago, :time => time_tag_without_link_to_activity(read_by_user["date"].to_time).html_safe);
            
            read_statuses[user_id] = read_by_user
        end
        return [users, read_statuses]
    end  

    def time_tag_without_link_to_activity(time) 
        return content_tag('abbr', distance_of_time_in_words(Time.now, time), :title => format_time(time))
    end
end
