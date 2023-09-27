class AdvancedMessengerHookListener < Redmine::Hook::ViewListener
    
    render_on :view_layouts_base_html_head, :partial => "advanced_messenger/html_head"
    
    def view_issues_history_journal_bottom(context={ })
        context[:controller].send(:render_to_string, {
            :partial => "advanced_messenger/history_journal_bottom",
            :locals => context
        })
    end
end