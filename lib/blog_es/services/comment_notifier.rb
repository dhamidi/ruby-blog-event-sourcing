module Blog
  module Services
    class CommentNotifier
      def initialize(mailer:, admin:, views:, posts:)
        @mailer = mailer
        @admin = admin
        @views = views
        @posts = posts
      end

      def handle_event(event)
        case event.name
        when :post_commented
          notify_about_comment(event)
        when :post_comment_rejected
          send_rejection_mail(event)
        end
      end

      def notify_about_comment(event)
        post = @posts.find(event.receiver_id)
        comment = Projections::Comment.new(event.get(:comment_id))
        comment.author = Projections::Author.new(
            event.get(:name),
            event.get(:email),
        )
        comment.body = event.get(:body)
        view = @views.create :post_commented_mail
        Presenter::PostCommented.new(view, post, comment).render
        message = Mailer::Message.new(subject: "Post commented", body: view.to_s)
        @mailer.send(@admin, message)
      end

      def send_rejection_mail(event)
        params = event.to_h
        to = params.fetch(:email).to_s
        reason = params.fetch(:reason, "").to_s
        body = "Your comment has been rejected.\n"
        body << "Reason: #{reason}\n" unless reason.empty?
        message = Blog::Mailer::Message.new(subject: "Commented rejected", body: body)
        @mailer.send(to, message)
      end
    end
  end

end
