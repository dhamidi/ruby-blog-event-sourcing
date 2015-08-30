module Blog
  module Presenter
    class CommentOnPost
      def initialize(view, comment)
        @view = view
        @comment = comment
      end

      def render
        @view.display :author, @comment.author.name
        @view.display :body, @comment.body
      end
    end

    class PostDetail
      def initialize(view, post, views)
        @view = view
        @views = views
        @post = post
        @no_comments = views.create :post_detail_no_comments
      end

      def render
        @view.display :title, @post.title
        @view.display :body, @post.body

        if @post.comment_count == 0
          @view.display :comments, @no_comments
        else
          render_comments
        end
      end

      def render_comments
        comments = @post.comments.map do |comment|
          view = @views.create :post_detail_comment
          CommentOnPost.new(view, comment).render
          view
        end

        @view.display :comments, View::Collection.new(comments)
      end
    end
  end
end
