require_dependency 'issue'

module Patches
  module AdvancedMessengerMessagePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:before_create, :create_read_by_users)
    end

    module InstanceMethods
      def create_read_by_users
          read_by_users_hash = {} 
          # Those are the users that are receiving mails when an issue is updates @see mailer.rb#deliver_issue_edit
          users = notified_users | root.notified_watchers | board.notified_watchers
          users.each do |user|
            read_by_users = {read: user.id == User.current.id ? AdvancedMessengerHelper::READ : AdvancedMessengerHelper::UNREAD, date: DateTime.now}
            read_by_users_hash[user.id.to_s] = read_by_users;
          end
          self.read_by_users = read_by_users_hash.to_json
      end
    end
  end
end