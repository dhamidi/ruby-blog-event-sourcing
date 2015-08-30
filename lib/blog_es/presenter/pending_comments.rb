module Blog
  module Presenter
    class PendingComment
      def initialize(view, post, comment)
        @view = view
        @post = post
        @comment = comment
      end

      def render
        @view.display :comment_id, @comment.id
        @view.display :author, @comment.author.name
        @view.display :body, @comment.body
        @view.display :email, @comment.author.email
        @view.display :written_at, @comment.written_at
        @view.display :action_accept, @post.links.rel(:accept_comment)
        @view.display :action_reject, @post.links.rel(:reject_comment)
      end
    end

    class PendingComments
      def initialize(view, post, views)
        @view = view
        @post = post
        @views = views
      end

      def render
        @view.display :post_title, @post.title
        @view.link :post_title, @post.links.rel(:self)

        if Array(@post.pending_comments).length > 0
          @view.display :comments, pending_comments
        else
          @view.display :comments, @views.create(:no_pending_comments)
        end
      end

      def pending_comments
        list = @views.create :pending_comments
        pending = Array(@post.pending_comments).map do |comment|
          view = @views.create :pending_comment
          PendingComment.new(view, @post, comment).render
          view
        end

        list.display :comments, View::Collection.new(pending)

        list
      end
    end
  end
end
