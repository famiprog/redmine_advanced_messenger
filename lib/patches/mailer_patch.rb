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
        unless user_excluded_from_email?(user, journal.issue.project)
          super_issue_edit(user, journal)
        end
      end

      def patched_message_posted(user, message)
        unless user_excluded_from_email?(user, message.project)
          super_message_posted(user, message)
        end
      end

      private

      def user_excluded_from_email?(user, project)
        user_roles_in_project = user.roles_for_project(project).map(&:id).map(&:to_s)
        roles_not_sent_email = (Setting.plugin_redmine_advanced_messenger[:roles_not_sent_email] || []).map(&:to_s)
        (user_roles_in_project & roles_not_sent_email).any?
      end      
      
    end
  end
end
