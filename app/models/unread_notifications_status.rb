class UnreadNotificationsStatus 
    attr_accessor :count
    attr_accessor :user
    attr_accessor :task

    def initialize(count = 0, user = nil, task = nil)
        @count = count
        @user = user
        @task = task
    end
end