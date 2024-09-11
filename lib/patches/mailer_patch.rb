require_dependency 'mailer'

module Patches
  module MailerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :super_issue_edit, :issue_edit
        alias_method :issue_edit, :patched_issue_edit
        
        alias_method :super_message_posted, :message_posted
        alias_method :message_posted, :patched_message_posted
      end
    end

    module InstanceMethods      
      def patched_issue_edit(user, journal)
        unless user_has_allowed_role?(user)
          super_issue_edit(user, journal)
        end
      end

      def patched_message_posted(user, message)
        unless user_has_allowed_role?(user)
          super_message_posted(user, message)
        end
      end

      private

      def user_has_allowed_role?(user)
        user_roles = user.roles.map(&:id).map(&:to_s)
        allowed_roles = (Setting.plugin_redmine_advanced_messenger[:allowed_roles] || []).map(&:to_s)
        (user_roles & allowed_roles).any?
      end      
      
    end
  end
end
