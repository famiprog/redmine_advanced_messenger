class UnreadNotificationsStatus 
    attr_accessor :count
    attr_accessor :user
    attr_accessor :parent

    def initialize(count = 0, user = nil, parent = nil)
        @count = count
        @user = user
        @parent = parent
    end
end