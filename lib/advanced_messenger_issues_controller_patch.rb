# This module could not be named IssuesControllerPatch
# because another module with same name exists in our other plugin: redmine_crispico_plugin, 
# and when requesting IssuesControllerPatch from redmine_crispico_plugin, it was resolved to IssuesControllerPatch from redmine_advanced_messenger
# That's why we prefixed it with the plugin name  
module AdvancedMessengerIssuesControllerPatch
    include ActionView::Helpers::JavaScriptHelper
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:after_action, :expand_collapse_notes, only: [:show])
    end
    
    module InstanceMethods
      def expand_collapse_notes
        expand_collapse_notes_or_messages(@journals, lambda {|journal| journal.notes[0, 130]}, lambda {|journal| journal.notes.nil?},
              # This regular expresion catches:
              #   <div id="journal-42-notes" class="wiki">
              #     <p>my note content</p>
              #   </div> 
              # and creates capture groups, in order to replace and obtain:
              #   <div id="journal-42-notes" class="wiki">
              #     <div class="message-content">
              #       <p>my note content</p>
              #     </div>
              #     <div class="message-preview">
              #     </div>
              #   </div>
              lambda {|journal_id| '(<div id="journal-' + journal_id + '-notes" class="wiki">)((?:.|\n)*?)(<\/div>)'},
            
              # These regular expresions for journal_id = 800 catches:
              #   <div id="change-800" class="journal">
              #     <div id="note-8" class="note">
              #       <div class="thumbnails" style="display: block;">
              #       </div>
              #     </div> 
              #   </div>
              # and creates capture groups, and replaces them to add the class "hidden" besides the class "thumbnails":
              #   <div id="change-800" class="journal">
              #     <div id="note-8" class="note">
              #       <div class="thumbnails hidden" style="display: block;">
              #       </div>
              #     </div>
              #   </div>

              # But it doesn't catches (for journal_id = 800):
              #   <div id="change-800" class="journal">
              #   </div>
              #   <div id="change-801" class="journal">
              #     <div id="note-8" class="note">
              #       <div class="thumbnails>
              #       </div>
              #     </div>
              #   </div>
              lambda {|journal_id| ['(<div id="change-' + journal_id + '"(?:(?!id="change)(?:.|\n))*?class="details)(")',
                                    '(<div id="change-' + journal_id + '"(?:(?!id="change)(?:.|\n))*?class="thumbnails)(")']})
      end
    end    
end