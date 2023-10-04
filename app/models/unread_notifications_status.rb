class UnreadNotificationsStatus 
    attr_accessor :count
    attr_accessor :user
    attr_accessor :issue

    def initialize(count = 0, user = nil, issue = nil)
        @count = count
        @user = user
        @issue = issue
    end
end