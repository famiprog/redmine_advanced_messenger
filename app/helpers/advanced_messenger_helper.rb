module AdvancedMessengerHelper
    def getUnreadNotificationsStatusses(issue)
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
end
