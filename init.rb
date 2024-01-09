Redmine::Plugin.register :redmine_advanced_messenger do
  require File.expand_path('lib/advanced_messenger_hook_listener', __dir__)

  name 'Redmine Advanced Messenger plugin'
  author 'famiprog'
  description 'For detailed documentation see the link below.'
  version '1.1.0'
  url 'https://github.com/famiprog/redmine-advanced-messenger'
  author_url 'https://github.com/famiprog'

  # default values for settings, and its render
  # Note: default values appear only when there are no settings saved in db.
  settings :default => {'empty' => true, 
                        :show_unread_notifications => '1', 
                        :unread_notifications_update_interval => 60}, 
            :partial => 'settings/advanced_messenger_settings'

  # need the helper to be available in _issue_notifications.html.erb 
  if Rails.version > '6.0' # Redmine 5.0
    Rails.application.config.after_initialize do
      # this is to expose helper methods to the hook class as they are used inside the controller hooks
      Redmine::Hook::Helper.include AdvancedMessengerHelper
    end
  else
    Rails.configuration.to_prepare do
      Redmine::Hook::Helper.include AdvancedMessengerHelper
    end
  end

  Journal.send(:include, Patches::JournalPatch)
  Message.send(:include, Patches::MessagePatch)
end
