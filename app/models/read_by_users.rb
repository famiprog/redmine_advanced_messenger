class ReadByUsers
    attr_accessor :read
    attr_accessor :date

    def initialize(read = 0, date = DateTime.now)
        @read = read
        @date = date
    end
end