class ReadByUsers
    # Basic initializer
    def initialize(read = 0, date = DateTime.now)
        # Assign the argument to the 'name' instance variable for the instance.
        @read = read
        # If no age given, we will fall back to the default in the arguments list.
        @date = date
    end

    def read=(read)
        @read = read
    end
    def read
        @read
    end

    def date=(date)
        @date = date
    end
    def date
        @date
    end
end