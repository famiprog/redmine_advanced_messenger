module AdvancedMessengerHelper

    def getUnreadJournalsStatus(journals)
        return getUnreadEntitiesStatus(journals, "indice", lambda {|entity| return entity.notes? });
    end

    def getUnreadMessagesStatus(messages)
        return getUnreadEntitiesStatus(messages, "id")
    end 

    def getUnreadEntitiesStatus(readableEntities, indexField, filterCondition = lambda {|entity| return true })
        unread_notifications_for_current_user = 0;
        unread_notifications_for_others = Hash.new;
        first_unread_notification_index = -1;

        readableEntities.each_with_index do |entity, index|
            next if entity.read_by_users == nil || !filterCondition.call(entity)
            read_by_users = JSON.parse(entity.read_by_users)
            read_by_users.each do |userId, value|
                if read_by_users[userId]["read"] == 0
                    if userId == User.current.id.to_s 
                        unread_notifications_for_current_user += 1
                        if first_unread_notification_index == -1 
                            first_unread_notification_index = entity.send(indexField)
                        end
                    else
                        if unread_notifications_for_others[userId] == nil
                            user = User.find(userId)
                            unread_notifications_for_others[userId] = UnreadNotificationsStatus.new(0, (user.firstname.capitalize + " " +  user.lastname.capitalize))  
                        end
                        unread_notifications_for_others[userId].count += 1
                    end
                end
            end
        end
        return [first_unread_notification_index, unread_notifications_for_current_user, unread_notifications_for_others]
    end

    def getUnreadNotificationsGroupByIssues() 
        unread_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%')
        getIssue = lambda {|entity| return entity.issue }
        return getUnreadNotificationsGroupByParentEntity(unread_notifications, getIssue)
    end

    def getUnreadNotificationsGroupByTopic() 
        getTopic = lambda {|entity| return entity.root != nil ? entity.root : entity }
        unread_notifications = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%')
        return getUnreadNotificationsGroupByParentEntity(unread_notifications, getTopic);
    end

    def getUnreadNotificationsGroupByParentEntity(unread_notifications, getParent) 
        unread_notifications_per_topic = Hash.new

        unread_notifications.each do |entity|
            parentEntity = getParent.call(entity)
            #TODO DB test if the topic (root message) has root= nil or roor = self 
            if unread_notifications_per_topic[parentEntity.id] != nil
                unread_notification_status = unread_notifications_per_topic[parentEntity.id]
            else
                # we set user to nil because is always the current user
                unread_notification_status = UnreadNotificationsStatus.new(0, nil, parentEntity)
                unread_notifications_per_topic[parentEntity.id] = unread_notification_status
            end
            unread_notification_status.count += 1 
        end
        return unread_notifications_per_topic
    end

    def getUnreadNotificationsForCurrentUserCount()
        unread_issues_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').count;
        unread_forum_messages = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').count
        return unread_forum_messages + unread_issues_notifications;
    end

    def getUsersReadStatus(read_by_users)
        read_by_users = JSON.parse(read_by_users)
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
            read_by_user["date"] = format_time(read_by_user["date"])
            read_statuses[user_id] = read_by_user
        end
        return [users, read_statuses]
    end    

end
