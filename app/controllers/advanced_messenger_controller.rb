class AdvancedMessengerController < ApplicationController

  def update_read_by_users
    @journal = Journal.find_by(id: params[:id])
    if @journal == nil
      Rails.logger.error("Could not find journal #{params[:id]}")
      render_404
      return
    end
    read_by_users = JSON.parse(@journal.read_by_users);
    if read_by_users[User.current.id.to_s] == nil
      Rails.logger.error("Change read status of journal #{params[:id]} for user #{User.current.id} is not allowed")
      render_404
      return
    end
    if not ["0", "1", "2"].include? params[:read_by_users]
      Rails.logger.error("#{params[:read_by_users]} is not a valid journal read status for a user")
      render_404
      return
    end

    read_by_users[User.current.id.to_s] = ReadByUsers.new params[:read_by_users].to_i
    @journal.read_by_users = read_by_users.to_json
    @journal.save

    @unread_notification_statuses = helpers.getUnreadNotificationsStatusses(@journal.issue)
    
    respond_to do |format|
      format.js
    end
  end
end
