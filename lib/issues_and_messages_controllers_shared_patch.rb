module IssuesAndMessagesControllersSharedPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:before_action, :init_users_cache, only: [:show])
    end
    
    module InstanceMethods
      def init_users_cache
        @users_cache = Hash.new
      end

      def expand_collapse_notes_or_messages(entities, getPreview, shouldExcludeEntity, getRegExToHideContent, getRegExesToHideOtherElements) 
        if (AdvancedMessengerSettings.get_setting(:disable_fix_for_scroll_to_anchor) == '1' || !User.current.logged?)
          return
        end

        entities.each do |entity|
          if shouldExcludeEntity.call(entity)
            next
          end  
          
          read_by_current_user = JSON.parse(entity.read_by_users)[User.current.id.to_s]
          expanded = false
          if read_by_current_user == nil || read_by_current_user["read"] == AdvancedMessengerHelper::READ || read_by_current_user["read"] == AdvancedMessengerHelper::READ_BRIEFLY || read_by_current_user["read"] == nil && !read_by_current_user["collapsed"]
            expanded = true
          end 
          #==========Add the content preview besides the actual content and hide/show the content/content preview==============
          truncated_notes = CGI::escapeHTML(getPreview.call(entity))
          # This was added because of https://redmine.xops-online.com/issues/35061
          # This happens because `truncated_notes` goes as the second parameter (the `replacement` parameter) of the gsub function.
          # And inside this `replacement` there can be some special constructions: https://www.rubydoc.info/stdlib/core/String:gsub 
          # As the above documentation suggests, the `\` should be escaped, if we want to prevent the interpretation of those constructions
          truncated_notes = truncated_notes.gsub("\\", "\\\\\\\\")
          if (read_by_current_user != nil && read_by_current_user["read"] != nil) 
            if (read_by_current_user["read"] == AdvancedMessengerHelper::UNREAD) 
              note_preview = "<span class='collapse-message-unread'>
                                #{t(:message_collapsed_unread)}
                              </span>"
            elsif (read_by_current_user["read"] == AdvancedMessengerHelper::IGNORED)
              note_preview ="<span class='collapse-message-ignored'>
                                #{t(:message_collapsed_ignored)}
                              </span>"
            else
              note_preview ="<span class='collapse-message-read'>
                                #{t(:message_collapsed_read)}
                              </span>
                              <span class='collapse-message-preview'>
                                #{truncated_notes}
                              </span>"
            end
          else 
            note_preview = "<span class='collapse-message'>
                              #{t(:message_collapsed)}
                            </span>
                            <span class='collapse-message-preview'> 
                              #{truncated_notes}
                            </span>"
          end

          to_replace = getRegExToHideContent.call(entity.id.to_s)
          with = "\\1
                  <div class='message-content #{!expanded ? " hidden" : ""}'>
                    \\2
                  </div>
                  <p class='message-preview #{expanded ? " hidden" : ""}'> 
                    #{!expanded ? note_preview : ""} 
                  </p>
                  \\3"                
          response.body = response.body.gsub(/#{to_replace}/, with)
          
          #==========In case not expanded hide other elements(e.g : .details, .thumbnails, .attachments divs)==============
          if !expanded
            getRegExesToHideOtherElements.call(entity.id.to_s).each do |regExToHideElement|
              response.body = response.body.gsub(/#{regExToHideElement}/, '\\1 hidden\\2')
            end  
          end  
        end
      end
    end    
end
