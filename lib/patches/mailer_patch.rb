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
        issue = journal.journalized

        redmine_headers 'Project' => issue.project.identifier,
                        'Issue-Tracker' => issue.tracker.name,
                        'Issue-Id' => issue.id,
                        'Issue-Author' => issue.author.login,
                        'Issue-Assignee' => assignee_for_header(issue)
        redmine_headers 'Issue-Priority' => issue.priority.name if issue.priority
        message_id journal
        references issue

        @author = journal.user
        @issue = issue
        @user = user
        @journal = journal
        @journal_details = journal.visible_details
        @issue_url = url_for(controller: 'issues', action: 'show', id: issue, anchor: "change-#{journal.id}")

        if Setting.plugin_redmine_advanced_messenger[:notifications_mail_option] == 'teaser'
          @note_teaser = ActionController::Base.helpers.truncate(journal.notes, length: 100, omission: '...')
          mail_content = @note_teaser
        else
          mail_content = journal.notes
        end

        subject = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
        subject += "(#{issue.status.name}) " if journal.new_value_for('status_id') && Setting.show_status_changes_in_mail_subject?
        subject += issue.subject

        mail to: user, subject: subject do |format|
          format.text { render plain: mail_content }
          format.html { render html: mail_content.html_safe }
        end
      end

      def patched_message_posted(user, message)
        redmine_headers 'Project' => message.project.identifier,
                        'Topic-Id' => (message.parent_id || message.id)
        message_id message
        references message.root
        @author = message.author
        @message = message
        @user = user
        @message_url = url_for(message.event_url)

        if Setting.plugin_redmine_advanced_messenger[:notifications_mail_option] == 'teaser'
          @message_teaser = ActionController::Base.helpers.truncate(message.content, length: 100, omission: '...')
          mail_content = @message_teaser
        else
          mail_content = message.content
        end

        subject = "[#{message.board.project.name} - #{message.board.name} - msg#{message.root.id}] #{message.subject}"

        mail to: user.mail, subject: subject do |format|
          format.text { render plain: mail_content }
          format.html { render html: mail_content.html_safe }
        end
      end
    end
  end
end
