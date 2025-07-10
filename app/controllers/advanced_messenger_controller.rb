class AdvancedMessengerController < ApplicationController
  include AdvancedMessengerHelper

  def update_journal_read_by_users
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    @journal = Journal.find_by(id: params[:id])
    update_entity_read_by_users(@journal, "journal", params[:id], params[:read_by_users],
                               method(:is_journal_visible),
                               lambda {|journal| @unread_notification_statuses = helpers.getUnreadJournalsStatus(journal.issue.visible_journals_with_index)})
  end

  def update_message_read_by_users
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    @message = Message.find_by(id: params[:id])
    update_entity_read_by_users(@message, "message", params[:id], params[:read_by_users],
                                method(:is_message_visible),
                                lambda {|message| 
                                        @replies =  @message.root.children
                                                                      .includes(:author, :attachments, {:board => :project})
                                                                      .reorder("#{Message.table_name}.created_on ASC, #{Message.table_name}.id ASC").
                                                                      to_a
                                        @unread_notification_statuses = helpers.getUnreadMessagesStatus([*@replies, @message.root])}
                                )
  end

  def update_entity_read_by_users(entity, entity_name, id, read_value, is_visible, response_setup)
    if entity == nil
      Rails.logger.error("Could not find  #{entity_name} #{id}")
      render_404
      return
    end
    
    if !is_visible.call(entity)
      Rails.logger.error("Current user doesn't have permissions to view #{entity_name} #{id}")
      render_403
      return
    end
    read_by_users = JSON.parse(entity.read_by_users);
    if not [AdvancedMessengerHelper::UNREAD.to_s, AdvancedMessengerHelper::READ_BRIEFLY.to_s, AdvancedMessengerHelper::READ.to_s, AdvancedMessengerHelper::READ_BUT_COLLAPSED.to_s, AdvancedMessengerHelper::IGNORED.to_s].include? read_value
      Rails.logger.error("#{read_value} is not a valid read status for a user")
      render_404
      return
    end

    set_current_user_new_read_collapsed_value(read_by_users, read_value);
    entity.read_by_users = read_by_users.to_json
    entity.save

    #setup variables needed in response (in update_journal_read_by_users.js.erb/update_message_read_by_users.js.erb)
    response_setup.call(entity)

    respond_to do |format|
      format.js
    end
  end

  # private helper method
  def set_current_user_new_read_collapsed_value(read_by_users, new_value)
    if read_by_users[User.current.id.to_s] == nil &&  new_value == AdvancedMessengerHelper::READ_BUT_COLLAPSED.to_s
      read_by_users[User.current.id.to_s] = {collapsed: 1}
    elsif read_by_users[User.current.id.to_s] != nil && read_by_users[User.current.id.to_s]["collapsed"] != nil && new_value == AdvancedMessengerHelper::READ.to_s
      read_by_users.delete(User.current.id.to_s)
    else  
      read_by_users[User.current.id.to_s] = {read: new_value.to_i, date: DateTime.now}
    end
  end

  def unread_notifications_count()
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    
    # read the details and compose notifications only if we are called from PWA (needs them to compose the notifications)
    # for the rest, use getNotificationsForCurrentUserCountByStatus()
    all_notifications = []
    if params[:for_pwa] == "true"
      # This can be generalized in two methods which call next SQL-s, in order to make the code easy to maintains
      unread_issues_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%")
      unread_forum_messages = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%")
    
      viewable_unread_issues_notifications = unread_issues_notifications.select do |notification|
          is_journal_visible(notification)
      end
      
      issue_notifications = viewable_unread_issues_notifications.map do |journal|
        {
          notificationId: journal.id,
          taskId: journal.journalized_id,
          taskSubject: journal.issue.subject,
          taskType: t(:label_issue),
          message: journal.notes,
          url: "/issues/#{journal.journalized_id}#note-#{journal.journalized.journals.order(:created_on).index(journal) + 1}",
          created_on: journal.created_on
        }
      end
    
      forum_notifications = unread_forum_messages.map do |message|
        taskId = message.parent_id.nil? ? message.id : message.parent_id
        {
          notificationId: message.id,
          taskId: taskId,
          parentTaskId: message.board_id,
          taskSubject: message.subject,
          taskType: t(:label_board),
          message: message.content,
          url: "/boards/#{message.board_id}/topics/#{taskId}" + (message.parent_id.nil? ? "" : "?page=#{((Message.where(parent_id: message.parent_id).order(:created_on).index(message) + 1).to_f / MessagesController::REPLIES_PER_PAGE).ceil}") + "#message-#{message.id}",
          created_on: message.created_on
        }
      end
    
      all_notifications = (issue_notifications + forum_notifications).sort_by { |n| n[:created_on] }.each do |n|
        # squish - remove spaces from start/end and then changes the remaining consecutive whitespace groups into one space each
        # " foo   bar    \n   \t   boo".squish # => "foo bar boo"
        n[:message] = truncate_message(n[:message].squish, {length: 150, omission: "...", escape: false, addTruncatePrefix: true})
        n[:title] = truncate_message((n[:taskType] + " #" + n[:taskId].to_s + ": " + n[:taskSubject]).squish, { length: 65, omission: "...", escape: false, addTruncatePrefix: true })
      end
    end

    respond_to do |format|
      format.json { render json: {count: getNotificationsForCurrentUserCountByStatus(AdvancedMessengerHelper::UNREAD), notifications: all_notifications}, status: 200 }
      format.html
    end
  end

  def read_briefly_notifications_count
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end

    respond_to do |format|
      format.json { render json: { count: getNotificationsForCurrentUserCountByStatus(AdvancedMessengerHelper::READ_BRIEFLY) }, status: 200 }
      format.html
    end
  end

  def ignore_all_unread_issues_notes
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    unread_issues_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    ignore_all_unread_entities(unread_issues_notifications, method(:is_journal_visible))
  end

  def ignore_all_unread_issues_notes_for_an_issue
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    unread_issue_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND journalized_id = ? AND read_by_users ILIKE ?", params[:issue_id], '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    ignore_all_unread_entities(unread_issue_notifications, method(:is_journal_visible))
  end

  def ignore_all_unread_forum_messages
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    unread_forum_messages = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    ignore_all_unread_entities(unread_forum_messages, method(:is_message_visible))
  end

  def ignore_all_unread_forum_messages_for_a_topic
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end
    unread_messages_for_topic = Message.where("(id = ? OR parent_id = ?) AND read_by_users ILIKE ?", params[:topic_id], params[:topic_id], '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    ignore_all_unread_entities(unread_messages_for_topic, method(:is_message_visible))
  end

  # private helper method
  def ignore_all_unread_entities(unread_entities, is_visible)
    unread_entities.each_with_index do |unread_entity, index|
      if is_visible.call(unread_entity) 
        change_read_status(unread_entity, IGNORED)
      end
    end

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  def mark_not_visible_journals_as_ignored_and_redirect
    unread_journals_for_issue = Journal.where("notes != '' AND notes IS NOT NULL AND journalized_id = ? AND read_by_users ILIKE ?", params[:issue_id], '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    mark_not_visible_entities_as_ignored_and_redirect(
      unread_journals_for_issue, 
      method(:is_journal_visible), 
      "/issues/#{params[:issue_id]}#note-#{params[:note_id]}"
    )
  end

  def mark_not_visible_messages_as_ignored_and_redirect
    unread_messages_for_topic = Message.where("(id = ? OR parent_id = ?) AND read_by_users ILIKE ?", params[:topic_id], params[:topic_id], '%"' + User.current.id.to_s + "\":{\"read\":#{AdvancedMessengerHelper::UNREAD}%");
    mark_not_visible_entities_as_ignored_and_redirect(
      unread_messages_for_topic, 
      method(:is_message_visible), 
      "/boards/#{params[:board_id]}/topics/#{params[:topic_id]}?page=#{params[:page_number]}#message-#{params[:unread_message_id]}"
    )
  end

  # private helper method
  def mark_not_visible_entities_as_ignored_and_redirect(entities, is_visible, redirect_url)
    entities.each do |entity|
      if !is_visible.call(entity)
        change_read_status(entity, IGNORED)
      end
    end
    redirect_to redirect_url
  end

  # private helper method
  # entity can be both journal or forum message
  def change_read_status(entity, status)
    read_by_users = JSON.parse(entity.read_by_users) 
    read_by_users[User.current.id.to_s]["read"] = status
    entity.read_by_users = read_by_users.to_json
    entity.save
  end

  def users_overview
    if !User.current.logged?
      Rails.logger.error("No logged in user")
      render_403
      return
    end

    # Default values
    @active_days = params[:active_days] || 30
    
    respond_to do |format|
      format.html
    end
  end
end

