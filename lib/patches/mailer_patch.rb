module Patches
  module MailerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :original_issue_edit, :issue_edit
        alias_method :original_message_posted, :message_posted
      end
    end

    module InstanceMethods
      def issue_edit(journal)
        user_roles = journal.user.roles.map(&:id).map(&:to_s)
        allowed_roles = Setting.plugin_redmine_advanced_messenger[:allowed_roles] || []
      
        if (user_roles & allowed_roles).empty?
          original_issue_edit(journal)
        end
      end
      
      def message_posted(message)
        user_roles = message.user.roles.map(&:id).map(&:to_s)
        allowed_roles = Setting.plugin_redmine_advanced_messenger[:allowed_roles] || []
      
        if (user_roles & allowed_roles).empty?
          original_message_posted(message)
        end
      end
    end
  end
end
