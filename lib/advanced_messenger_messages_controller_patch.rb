# @see AdvancedMessengerIssuesControllerPatch for an explanation about the naming of this module
module AdvancedMessengerMessagesControllerPatch
    include ActionView::Helpers::JavaScriptHelper
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:after_action, :expand_collapse_messages, only: [:show])
    end
    
    module InstanceMethods
      def expand_collapse_messages
          # The following regexes resemble. 
          # For example the third regular expression, for message_id = 800, it catches:
          #   <div class="message reply" id="message-800">
          #     <div class="wiki">
          #     </div> 
          #   </div>
          # But it doesn't catches (for message_id = 800):
          #   <div class="message reply" id="message-800"> 
          #   </div>
          #   <div class="message reply" id="message-801">
          #     <div class="wiki">
          #     </div> 
          #   </div>

          # All the expressions below creates capture groups in two ways:
      
          # 1. By adding 3 capture groups so that it can wrap them like: 
          #   \\1addition_1\\2addition_2\\3addition_3 i.e.:
          #   \\1<div class='message-content hidden'>\\2</div><p class='message-preview'>preview</p>\\3"  
          
          # 2. By adding only two capture groups so it cand add the "hidden" css class between them:
          #   \\1 hidden\\2 
        expand_collapse_notes_or_messages([@topic], lambda {|message| message.content.to_s[0, 130]}, lambda {|message| false},
          lambda {|message_id| '(class="message">(?:(?!id="message-)(?:.|\n))*?class="wiki">)((?:.|\n)*?)(<\/div>)'},
          lambda {|message_id| ['(class="message">(?:(?!id="message-)(?:.|\n))*?class="attachments)(")']})

        expand_collapse_notes_or_messages(@replies, lambda {|message| message.content.to_s[0, 130]}, lambda {|message| false},
          lambda {|message_id| '(id="message-' + message_id + '"(?:(?!id="message-)(?:.|\n))*?class="wiki">)((?:.|\n)*?)(<\/div>)'},
          lambda {|message_id| ['(id="message-' + message_id + '"(?:(?!id="message-)(?:.|\n))*?class="attachments)(")']})
      end
    end    
end