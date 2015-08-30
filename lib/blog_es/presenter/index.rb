module Blog
  module Presenter
    class Index
      def initialize(view, posts, views)
        @view = view
        @posts = posts.map do |post|
          view = views.create(:post_on_index)
          PostOnIndex.new(view, post).render
          view
        end
      end

      def render
        @view.display :posts, View::Collection.new(@posts)
      end
    end
  end
end
