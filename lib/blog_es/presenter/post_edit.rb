module Blog
  module Presenter
    class PostEdit
      def initialize(view, post)
        @view = view
        @post = post
      end

      def render
        @view.display :post_title, @post.title
        @view.display :post_body, @post.body
        @view.display :post_edit, @post.links.rel(:edit)
      end
    end
  end
end
