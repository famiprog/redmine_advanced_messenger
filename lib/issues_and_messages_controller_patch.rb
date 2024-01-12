module IssuesAndMessagesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:before_action, :init_users_cache, only: [:show])
    end
    
    module InstanceMethods
      def init_users_cache
        @users_cache = Hash.new
      end
    end    
end
