Redmine::Plugin.register :redmine_advanced_messenger do
  require File.expand_path('lib/advanced_messenger_hook_listener', __dir__)

  name 'Redmine Advanced Messenger plugin'
  author 'famiprog'
  description 'For detailed documentation see the link below.'
  version '1.1.0'
  url 'https://github.com/famiprog/redmine-advanced-messenger'
  author_url 'https://github.com/famiprog'

  # need the helper to be available in _issue_notifications.html.erb 
  if Rails.version > '6.0' # Redmine 5.0
    Rails.application.config.after_initialize do
      # this is to expose helper methods to the hook class as they are used inside the controller hooks
      Redmine::Hook::Helper.include AdvancedMessengerHelper
      IssuesController.send(:include, IssuesAndMessagesControllerPatch)
      MessagesController.send(:include, IssuesAndMessagesControllerPatch)
	end
  else
    Rails.configuration.to_prepare do
      Redmine::Hook::Helper.include AdvancedMessengerHelper
    end
  end

  Journal.send(:include, Patches::JournalPatch)
  Message.send(:include, Patches::MessagePatch)
end
