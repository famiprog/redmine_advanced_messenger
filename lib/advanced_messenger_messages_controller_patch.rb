# @see AdvancedMessengerIssuesControllerPatch for an explanation about the naming of this module
module AdvancedMessengerMessagesControllerPatch
  include ActionView::Helpers::JavaScriptHelper
  def self.included(base)
    IssuesAndMessagesControllersSharedPatch.included(base)
    base.send(:include, InstanceMethods)
    base.send(:after_action, :expand_collapse_messages, only: [:show])
  end
  
  module InstanceMethods
    def expand_collapse_messages
        # The first and the third regexps resambles regarding the capturing groups: 
        # It both adds 3 capture groups so that it can wrap them like: 
        #   \\1<div class='message-content hidden'>\\2</div><p class='message-preview'>preview</p>\\3"  
        
        # The second and the last regexps resambles regarding the capturing groups: 
        # It both adds only two capture groups so it can add the "hidden" css class between them:
        #   \\1 hidden\\2 
        
      expand_collapse_notes_or_messages([@topic], lambda {|message| truncate_message(message.content.to_s)}, lambda {|message| false},
       # The following regexp catches:
        #   <div class="message">
        #     <div class="wiki">
        #     </div> 
        #   </div>
        # But it doesn't catch:
        #   <div class="message"> 
        #   </div>
        #   <div class="message reply" id="message-801">
        #     <div class="wiki">
        #     </div> 
        #   </div>
        lambda {|message_id| '(class="message">(?:(?!id="message-)(?:.|\n))*?class="wiki">)((?:.|\n)*?)(<\/div>)'},
        # This regexp resambles to the initial part of the one above, except the capturing groups and the "wiki" keyword)
        lambda {|message_id| ['(class="message">(?:(?!id="message-)(?:.|\n))*?class="attachments)(")']})

      expand_collapse_notes_or_messages(@replies, lambda {|message| truncate_message(message.content.to_s)}, lambda {|message| false},
        # The following regexp it catches:
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
        lambda {|message_id| '(id="message-' + message_id + '"(?:(?!id="message-)(?:.|\n))*?class="wiki">)((?:.|\n)*?)(<\/div>)'},
        # This regexp resambles to the initial part of the one above, except the capturing groups and the "wiki" keyword)
        lambda {|message_id| ['(id="message-' + message_id + '"(?:(?!id="message-)(?:.|\n))*?class="attachments)(")']})
    end
  end    
end