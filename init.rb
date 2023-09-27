Redmine::Plugin.register :redmine_advanced_messenger do
  require File.expand_path('lib/advanced_messenger_hook_listener', __dir__)

  name 'Redmine Advanced Messenger plugin'
  author 'famiprog'
  description 'For detailed documentation see the link below.'
  version '0.0.1'
  url 'https://github.com/famiprog/redmine-advanced-messenger'
  author_url 'https://github.com/famiprog'

  Journal.send(:include, Patches::JournalPatch)
end
