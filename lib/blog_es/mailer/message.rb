module Blog::Mailer
  class Message
    attr_reader :subject, :body, :from

    def initialize(subject:, body:, from:'')
      @subject = subject.strip
      @body = body.strip
      @from = from

      raise ArgumentError.new("body: required") if @body.empty?
      raise ArgumentError.new("subject: required") if @subject.empty?
    end

    def ==(other)
      subject == subject && body == body && from == from
    end

    def sign_as(name, email)
      @from = "\"#{name}\" <#{email}>"
    end

    def to_mail
      result = %Q{Subject: #{subject}\r\n}
      result << %Q{From: #{from}\r\n} unless from.empty?
      result << "\r\n\r\n"
      result << body
      result << "\n"

      result
    end
  end
end
