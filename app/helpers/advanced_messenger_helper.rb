module AdvancedMessengerHelper
    # needed for truncate_message for using escape_javascript and truncate methods
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TextHelper

    UNREAD = 0
    READ = 1
    READ_BUT_COLLAPSED = 2
    IGNORED = 3
    READ_BRIEFLY = 4

    def getUnreadJournalsStatus(journals)
        return getUnreadEntitiesStatus(journals, "indice", lambda {|entity| return entity.notes? });
    end

    def getUnreadMessagesStatus(messages)
        return getUnreadEntitiesStatus(messages, "id")
    end 

    def getFirstReadBrieflyNotification(readableEntities, indexField)
        readableEntities.each_with_index do |entity, index|
            next unless entity.read_by_users
            JSON.parse(entity.read_by_users).each do |userId, value|
                return entity.send(indexField) if value["read"] == READ_BRIEFLY && userId == User.current.id.to_s
            end
        end
    end

    def getFirstMessageIdAndPageNumber(topic, read_status)
        message = Message.where("read_by_users ILIKE ?", "%\"#{User.current.id}\":{\"read\":#{read_status}%").where("parent_id = :topic_id OR (parent_id IS NULL AND id = :topic_id)", topic_id: topic.id).order(:created_on).first
        return nil if message.nil?
        if message.parent_id.nil?
            page_number = -1
            message_id = -1
        else
            page_number = ((Message.where(parent_id: topic.id).order(:created_on).index(message) + 1).to_f / MessagesController::REPLIES_PER_PAGE).ceil
            message_id = message.id
        end
        return [message_id, page_number]
    end

    def getUnreadEntitiesStatus(readableEntities, indexField, filterCondition = lambda {|entity| return true })
        unread_notifications_for_current_user = 0;
        unread_notifications_for_others = Hash.new;
        first_unread_notification_index = -1;

        readableEntities.each_with_index do |entity, index|
            next if entity.read_by_users == nil || !filterCondition.call(entity)
            read_by_users = JSON.parse(entity.read_by_users)
            read_by_users.each do |userId, value|
                if read_by_users[userId]["read"] == UNREAD
                    if userId == User.current.id.to_s 
                        unread_notifications_for_current_user += 1
                        if first_unread_notification_index == -1 
                            first_unread_notification_index = entity.send(indexField)
                        end
                    else
                        if unread_notifications_for_others[userId] == nil
                            user = User.find(userId) rescue nil
                            if user == nil
                                read_by_users.delete(userId)
                                next
                            end
                            unread_notifications_for_others[userId] = NotificationsStatus.new(0, (user.firstname.capitalize + " " +  user.lastname.capitalize))  
                        end
                        unread_notifications_for_others[userId].count += 1
                    end
                end
            end
        end
        return [first_unread_notification_index, unread_notifications_for_current_user, unread_notifications_for_others]
    end

    def getNotificationsGroupByIssues(read_status)
        notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", "%\"#{User.current.id}\":{\"read\":#{read_status}%").order("created_on desc")
        getIssue = lambda { |entity| return entity.issue }
        return getNotificationsGroupByParentEntity(notifications, getIssue)
      end

    def getNotificationsGroupByTopic(read_status) 
        getTopic = lambda { |entity| return entity.root }
        notifications = Message.where("read_by_users ILIKE ?", "%\"#{User.current.id}\":{\"read\":#{read_status}%").order("created_on desc")
        return getNotificationsGroupByParentEntity(notifications, getTopic);
    end

    def getNotificationsGroupByParentEntity(notifications, getParent) 
        grouped_notifications = Hash.new

        notifications.each do |entity|
            parentEntity = getParent.call(entity)
            # Determine if the entity is visible to the user
            if grouped_notifications[parentEntity.id] != nil
                notification_status = grouped_notifications[parentEntity.id]
            else
                # we set user to nil because is always the current user
                notification_status = NotificationsStatus.new(0, nil, parentEntity)
                grouped_notifications[parentEntity.id] = notification_status
            end
            notification_status.count += 1 
        end
        return grouped_notifications
    end

    def getNotificationsGroupByIssuesAndProjects(read_status)
        notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", "%\"#{User.current.id}\":{\"read\":#{read_status}%").order("created_on desc")
        getIssue = lambda { |entity| return entity.issue }
        return getNotificationsGroupByParentEntityAndProject(notifications, getIssue)
    end

    def getNotificationsGroupByTopicAndProjects(read_status) 
        getTopic = lambda { |entity| return entity.root }
        notifications = Message.where("read_by_users ILIKE ?", "%\"#{User.current.id}\":{\"read\":#{read_status}%").order("created_on desc")
        return getNotificationsGroupByParentEntityAndProject(notifications, getTopic);
    end

    def getNotificationsGroupByParentEntityAndProject(notifications, getParent) 
        grouped_notifications_by_project = Hash.new

        notifications.each do |entity|
            parentEntity = getParent.call(entity)
            
            # Get project for grouping
            project = nil
            if parentEntity.is_a?(Issue)
                project = parentEntity.project
            elsif parentEntity.is_a?(Message)
                project = parentEntity.board.project
            end
            
            project_id = project ? project.id : 'no_project'
            
            # Initialize project group if it doesn't exist
            if grouped_notifications_by_project[project_id] == nil
                grouped_notifications_by_project[project_id] = {
                    project: project,
                    notifications: Hash.new
                }
            end
            
            # Group by parent entity within project
            if grouped_notifications_by_project[project_id][:notifications][parentEntity.id] != nil
                notification_status = grouped_notifications_by_project[project_id][:notifications][parentEntity.id]
            else
                notification_status = NotificationsStatus.new(0, nil, parentEntity)
                grouped_notifications_by_project[project_id][:notifications][parentEntity.id] = notification_status
            end
            notification_status.count += 1 
        end
        
        # Sort projects alphabetically by name
        sorted_grouped_notifications = {}
        grouped_notifications_by_project.sort_by do |project_id, project_data|
            if project_data[:project]
                project_data[:project].name.downcase
            else
                'zzzz' # Put projects without names at the end
            end
        end.each do |project_id, project_data|
            sorted_grouped_notifications[project_id] = project_data
        end
        
        return sorted_grouped_notifications
    end

    def getNotificationsForCurrentUserCountByStatus(status)
        unread_issues_notifications_count = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{status}%").count
        unread_forum_messages_count = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{status}%").count
        return unread_forum_messages_count + unread_issues_notifications_count;
    end

    def getUsersReadStatus(read_by_users)
        read_by_users = JSON.parse(read_by_users)
        read_statuses = Hash.new
        # Not always a global cache is needed. 
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
            	user = User.find(user_id) rescue nil
                if user == nil
                    read_by_users.delete(user_id)
                    next
                end
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
        return { users: users, read_statuses: read_statuses }
    end
    
    def time_tag_without_link_to_activity(time) 
        return content_tag('abbr', distance_of_time_in_words(Time.now, time), :title => format_time(time))
    end   

    def is_journal_visible (journal)
        return journal.journalized.visible? && User.current.allowed_to?(:view_issues, journal.journalized.project) && (!journal.private_notes? || User.current.allowed_to?(:view_private_notes, journal.journalized.project) || journal.user.id == User.current.id)
    end

    def is_message_visible (message)
        return message.visible?();  
    end

    def truncate_message_and_escape_javascript(message, options = {length: 150, omission: "...", escape: false, addTruncatePrefix: false})
        return escape_javascript(truncate_message(message, options))
    end    

    # Truncate the message if it's not blank.
    # Type options = { length, omission, separator, escape }, default: {length: 150, omission: "...", escape: false}
    # If options contains addTruncatePrefix = true then l(:message_truncated) will be added as prefix for the truncated message
    # Default length is 150, so the real length for the message will be 147 because the default for omission contains 3 characters as well and disable escape for HTML.
    # Check https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-truncate for more documentation.
    def truncate_message(message, options = {length: 150, omission: "...", escape: false, addTruncatePrefix: false})
        return "" if message.blank?
        return truncate(message, options) if !options[:addTruncatePrefix]

        initialMessageLength = message.length
        messageAfterTruncate = truncate(message, options)
        return (initialMessageLength != messageAfterTruncate.length ? "[#{l(:message_truncated)}] " : "") + messageAfterTruncate
    end

    def check_if_teaser_and_user_not_excepted_from_teaser(user_id)
        return Setting.plugin_redmine_advanced_messenger[:notifications_mail_option] == 'teaser' && !Array(Setting.plugin_redmine_advanced_messenger[:user_excepted_from_the_teaser_process_option].map(&:to_i)).include?(user_id)
    end
end
