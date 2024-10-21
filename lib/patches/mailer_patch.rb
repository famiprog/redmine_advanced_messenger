require_dependency 'mailer'

module Patches
  module MailerPatch
    # foce this helper, since apparently the patcher does not inherit the 
    # helpers from parent, or the mailer (which is not a controller) behaves
    # differently. The end result is that helpers() function is not available 
    # in the patch (and probably neither in mailer?)
    include IssuesHelper

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
        details = []
        # get the details_to_string only if we have notifications on all the modifications from a issue
        if Setting.notified_events.include?('issue_updated')
          details = details_to_strings(journal.visible_details, true, :only_path => false)
        end
        # We want "Roles to exclude from email notifications" to only block notifications for notes added.
        # But when adding notes, the user can make other modifications, which should send notification by email 
        # (depending on the redmine configuration)
        # So we need to copy the code from Journal that checks everything before sending a notification.
        # If the user configured to be notified on all updates, we use the user_excluded_from_email function (that
        # is also used in template) to see if we have fields completed. The second parameter (no_html) is set to true
        # because 1/ we are not intereseted in html and the time needed to fill it and 2/ apaprently there is a problem
        # when calling helper from mailer. We had to force including IssuesHelper (which contains the function) but 
        # the html code also calls other functions from other helpers (e.g. h()) which is not available
        if 
          Setting.notified_events.include?('issue_updated') && (details.size > 0  || !user_excluded_from_email?(user, journal.issue.project)) || 
          (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
          (Setting.notified_events.include?('issue_assigned_to_updated') && journal.detail_for_attribute('assigned_to_id').present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?) ||
          (Setting.notified_events.include?('issue_fixed_version_updated') && journal.detail_for_attribute('fixed_version_id').present?) ||
          (Setting.notified_events.include?('issue_attachment_added') && journal.details.any? {|d| d.property == 'attachment' && d.value }) ||
          (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) && !user_excluded_from_email?(user, journal.issue.project)
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
