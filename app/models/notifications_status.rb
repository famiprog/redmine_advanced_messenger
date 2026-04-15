class NotificationsStatus 
    attr_accessor :count
    attr_accessor :user
    attr_accessor :parent
    attr_accessor :last_notification

    def initialize(count = 0, user = nil, parent = nil)
        @count = count
        @user = user
        @parent = parent
        @last_notification = nil
    end
end