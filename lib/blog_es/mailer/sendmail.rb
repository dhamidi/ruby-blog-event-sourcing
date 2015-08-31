module Blog::Mailer
  class Sendmail
    def initialize(sendmail_program="/usr/sbin/sendmail")
      @sendmail_program = sendmail_program
    end

    def send(to, message)
      `#{@sendmail_program} #{to} <<EOF
#{message.to_mail}
.
EOF`
    end
  end
end
