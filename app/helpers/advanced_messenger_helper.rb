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
        unread_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').order("created_on desc")
        getIssue = lambda {|entity| return entity.issue }
        return getUnreadNotificationsGroupByParentEntity(unread_notifications, getIssue)
    end

    def getUnreadNotificationsGroupByTopic() 
        getTopic = lambda {|entity| return entity.root }
        unread_notifications = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').order("created_on desc")
        return getUnreadNotificationsGroupByParentEntity(unread_notifications, getTopic);
    end

    def getUnreadNotificationsGroupByParentEntity(unread_notifications, getParent) 
        grouped_unread_notifications = Hash.new

        unread_notifications.each do |entity|
            parentEntity = getParent.call(entity)
            # Determine if the entity is visible to the user
            entity_is_visible = entity_visible_to_user?(entity, parentEntity.project)
            next unless entity_is_visible
            if grouped_unread_notifications[parentEntity.id] != nil
                unread_notification_status = grouped_unread_notifications[parentEntity.id]
            else
                # we set user to nil because is always the current user
                unread_notification_status = UnreadNotificationsStatus.new(0, nil, parentEntity)
                grouped_unread_notifications[parentEntity.id] = unread_notification_status
            end
            unread_notification_status.count += 1 
            unread_notification_status.unread_journals << entity
        end
        return grouped_unread_notifications
    end

    def entity_visible_to_user?(entity, project)
        if entity.is_a?(Journal)
            user_can_view_private_notes = User.current.allowed_to?(:view_private_notes, project)
            user_can_view_issues = User.current.allowed_to?(:view_issues, project)
            return false unless user_can_view_issues
            return !entity.private_notes? || user_can_view_private_notes
        else
            return true
        end
    end

    def getUnreadNotificationsForCurrentUserCount()
        unread_issues_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%')
        unread_forum_messages = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%')

        # Filter out private notifications the user can't view
        viewable_unread_issues_notifications = unread_issues_notifications.select do |notification|
            is_journal_visible(notification)
        end

        return unread_forum_messages.count + viewable_unread_issues_notifications.count;
    end

    def getUsersReadStatus(read_by_users)
        read_by_users = JSON.parse(read_by_users)
        read_statuses = Hash.new
        # Not always a gloabal cache is needded. 
        # Only in case getUsersReadStatus() is caller repeatedly: e.g. Called for every journal/message when displaying the issues/forum topic page with all its notes/forum messages
        # For the case getUsersReadStatus() is called only once, the global cache is not needed : e.g. After updating the read status of a single note/message (@see update_journal_read_by_users.js.erb) 
        users_cache = @users_cache != nil ? @users_cache : Hash.new
        users = Hash.new
        read_by_users.keys.each_with_index do |user_id, index|
            if (!read_by_users[user_id]["read"]) 
                # no read status for this user i.e. the note is not of interest for him
                next
            end
            if (users_cache[user_id] == nil)
            	user = User.find(user_id)
            	user_short = Hash.new
            	user_short["firstname"] = user.firstname
            	user_short["lastname"] = user.lastname
            	user_short["link"] = link_to_user(user)
            	users_cache[user_id] = user_short 
			end
            users[user_id] = users_cache[user_id]
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

    def is_journal_visible (journal)
        return journal.journalized.visible? && (!journal.private_notes? || User.current.allowed_to?(:view_private_notes, journal.journalized.project) || journal.user.id == User.current.id)
    end

    def is_message_visible (message)
        return message.visible?();  
    end
end
