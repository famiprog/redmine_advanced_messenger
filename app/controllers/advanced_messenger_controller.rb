class AdvancedMessengerController < ApplicationController

  def update_journal_read_by_users
    @journal = Journal.find_by(id: params[:id])
    update_entity_read_by_users(@journal, "journal", params[:id], params[:read_by_users],
                               lambda {|journal| return journal.journalized.visible? && (!journal.private_notes? || User.current.allowed_to?(:view_private_notes, journal.journalized.project) || journal.user.id == User.current.id)},
                               lambda {|journal| @unread_notification_statuses = helpers.getUnreadJournalsStatus(journal.issue.visible_journals_with_index)})
  end

  def update_message_read_by_users
    @message = Message.find_by(id: params[:id])
    update_entity_read_by_users(@message, "message", params[:id], params[:read_by_users],
                                lambda {|message| return message.visible?()},
                                lambda {|message| 
                                        @replies =  @message.root.children
                                                                      .includes(:author, :attachments, {:board => :project})
                                                                      .reorder("#{Message.table_name}.created_on ASC, #{Message.table_name}.id ASC").
                                                                      to_a
                                        @unread_notification_statuses = helpers.getUnreadMessagesStatus([*@replies, @message.root])}
                                )
  end

  # The read field can have the following values
  # 0 -> unread
  # 1 -> read
  # 2 -> read but collapsed
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
    if not ["0", "1", "2"].include? read_value
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

  def set_current_user_new_read_collapsed_value(read_by_users, new_value)
    if read_by_users[User.current.id.to_s] == nil &&  new_value == "2"
      read_by_users[User.current.id.to_s] = {collapsed: 1}
    elsif read_by_users[User.current.id.to_s] != nil && read_by_users[User.current.id.to_s]["collapsed"] != nil && new_value == "1"
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

    unread_issues_notifications = Journal.where("notes != '' AND notes IS NOT NULL AND read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').count;
    unread_forum_messages = Message.where("read_by_users ILIKE ?", '%"' + User.current.id.to_s + '":{"read":0%').count

    respond_to do |format|
      format.json { render json: {count: unread_forum_messages + unread_issues_notifications}, status: 200 }
      format.html
    end
  end
end
