class AdvancedMessengerSettings

    public

    def self.get_setting(name)
        return Setting.plugin_redmine_advanced_messenger[name]
    end
end