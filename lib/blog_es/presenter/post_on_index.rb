module Blog
  module Presenter
    class PostOnIndex
      def initialize(view, post)
        @view = view
        @post = post
      end

      def render
        @view.display :title, @post.title
        @view.link :title, @post.links.rel(:self)
        @view.display :summary, @post.summary
        @view.display :comments, comments

        self
      end

      def comments
        case @post.comment_count
        when 0
          "no comments"
        when 1
          "one comment"
        else
          "#{@post.comment_count} comments"
        end
      end
    end
  end
end
