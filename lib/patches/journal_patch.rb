require_dependency 'issue'

module Patches
  module JournalPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      # Initially the read_by_users was populated `before_create`.
      # It was moved to `after_create_commit` as a workaround to the fact that the
      # `notified_mentiones` are computed only `after_save` (@see mentionable#parse_mentions) 
      base.send(:after_create_commit, :create_read_by_users)
    end

    module InstanceMethods
      def create_read_by_users
        if (notes.present?) 
          read_by_users_hash = {} 
          # Those are the users that are receiving mails when an issue is updates @see mailer.rb#deliver_issue_edit
          users = notified_users | notified_watchers | notified_mentions | journalized.notified_mentions
          users.each do |user|
            read_by_users = {read: user.id == User.current.id ? 1 : 0, date: DateTime.now}
            read_by_users_hash[user.id.to_s] = read_by_users;
          end
          self.read_by_users = read_by_users_hash.to_json
          self.save
        end
      end
    end
  end
end