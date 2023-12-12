class DocumentWriter
    
    attr_accessor :status, :message

    OK = 1
    WARNING = 2
    FATAL = 3

    def set_error(error, msg)
        @status = error
        @message = msg
    end


end