module Blog::Mailer
  class Message
    attr_reader :subject, :body

    def initialize(subject:, body:)
      @subject = subject.strip
      @body = body.strip

      raise ArgumentError.new("body: required") if @body.empty?
      raise ArgumentError.new("subject: required") if @subject.empty?
    end
  end
end
