module Blog::Mailer
  class InMemory
    attr_accessor :messages

    def initialize
      @messages = []
    end

    def send(to, message)
      envelope = Envelope.new(to: to, message: message)
      @messages << envelope
    end
  end
end
