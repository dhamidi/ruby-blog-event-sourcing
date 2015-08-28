module Blog::Mailer
  class Envelope
    attr_reader :to, :message
    def initialize(to:, message:)
      @to = to
      @message = message
    end
  end
end
