require_dependency 'issue'

module Patches
  module AdvancedMessengerJournalPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:before_create, :create_read_by_users)
    end

    module InstanceMethods
      def create_read_by_users
        if (notes.present?) 
          read_by_users_hash = {} 
          # The `notified_mentions` (used by mailer) are computed `after_save` (@see mentionable#parse_mentions)
          # But here we need it `before_create`, that's why we need to compute them here also
          # `get_mentioned_users` is private inside `Mentionable` module that's why we need to call it this way
          notified_mentiones = self.send(:get_mentioned_users, nil, notes);
          issue_notified_mentiones = self.send(:get_mentioned_users, nil, journalized.description);
          # These are the users that are receiving mails when an issue is updated @see mailer.rb#deliver_issue_edit
          users = notified_users | notified_watchers | 
                  (notified_mentiones == nil ? [] : notified_mentiones) | 
                  (issue_notified_mentiones == nil ? [] : issue_notified_mentiones);
          users.each do |user|
            read_by_users = {read: user.id == User.current.id ? AdvancedMessengerHelper::READ : AdvancedMessengerHelper::UNREAD, date: DateTime.now}
            read_by_users_hash[user.id.to_s] = read_by_users;
          end
          self.read_by_users = read_by_users_hash.to_json
        end
      end
    end
  end
end