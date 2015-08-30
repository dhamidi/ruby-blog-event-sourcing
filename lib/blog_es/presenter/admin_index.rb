module Blog
  module Presenter
    class AdminPostOnIndex
      def initialize(view, post)
        @view = view
        @post = post
      end

      def render
        @view.display :post_title, @post.title
        @view.display :pending_comment_count, "%d pending comments" %
                                              Array(@post.pending_comments).length
        @view.link :pending_comment_count, @post.links.rel(:pending_comments)
        @view.display :action_edit, "Edit"
        @view.link :action_edit, @post.links.rel(:edit)
      end
    end
    class AdminIndex
      def initialize(view, posts, views)
        @view = view
        @posts = posts
        @views = views
      end

      def render
        @view.display :posts, View::Collection.new(posts)
      end

      def posts
        Array(@posts).map do |post|
          view = @views.create :admin_post_on_index
          AdminPostOnIndex.new(view, post).render
          view
        end
      end
    end
  end
end
