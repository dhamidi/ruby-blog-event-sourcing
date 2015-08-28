module Blog::Services
  class CommentNotifier
    def initialize(mailer:)
      @mailer = mailer
    end

    def handle_event(event)
      case event.name
      when :post_comment_rejected
        send_rejection_mail(event)
      end
    end

    def send_rejection_mail(event)
      params = event.to_h
      to = params.fetch(:email)
      reason = params.fetch(:reason, "")
      body = "Your comment has been rejected.\n"
      body << "Reason: #{reason}\n" unless reason.empty?
      message = Blog::Mailer::Message.new(subject: "Commented rejected", body: body)
      @mailer.send(to, message)
    end
  end
end
