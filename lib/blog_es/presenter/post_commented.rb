module Blog
  module Presenter
    class PostCommented
      def initialize(view, post, comment)
        @view = view
        @post = post
        @comment = comment
      end

      def render
        @view.display :post_title, @post.title
        @view.link :post_title, @post.links.rel(:self)
        @view.display :comment_body, @comment.body
        @view.display :commenter, @comment.author.name
        @view.display :commenter_email, @comment.author.email
      end
    end
  end
end
