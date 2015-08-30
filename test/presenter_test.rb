require 'test_helper'

module Blog
  module Presenter
    class PresenterTest < Minitest::Spec
      class DummyView
        def initialize
          @log = []
        end

        def display(key, value)
          @log.push [:"display_#{key}",value]
        end

        def link(key, href)
          @log.push [:"link_#{key}", href]
        end

        def log
          @log
        end
      end

      def make_post(id:,title:,body:,comments:)
        subject = Projections::Post.new
        subject.title = title
        subject.body = body
        subject.comments = [comments.times { Projections::Comment.new }]
        subject.links = Projections::Links.new
        subject.links.add(:self, "/#{id}")

        subject
      end


      describe Index do
        it "renders all posts" do
          views = View::Views.new
          views.add :index do
            View::HTML.new '%{posts}'
          end

          views.add :post_on_index do
            View::HTML.new '%{title}'
          end

          posts = [
            make_post(id: 'first', title: 'first', body: 'first', comments: 0),
            make_post(id: 'second', title: 'second', body: 'second', comments: 0),
          ]

          view = views.create(:index)
          index = Index.new(view, posts, views)

          index.render

          expected = '<a href="/first">first</a><a href="/second">second</a>'
          value(view.to_s).must_equal(expected)
        end
      end

      describe PostOnIndex do
        let(:post) do
          make_post(id: 'the-post',
                    title: "post title",
                    body: "first paragraph\n\nsecond paragraph",
                    comments: 0)
        end

        let(:view) do
          DummyView.new
        end

        let(:presenter) do
          PostOnIndex.new(view, post)
        end

        it "renders the post's title" do
          presenter.render

          value(view.log).must_include([:display_title,  "post title"])
        end

        it "links the title to the post's page" do
          presenter.render

          value(view.log).must_include([:link_title, "/the-post"])
        end

        it "renders the post's first paragraph as a summary" do
          presenter.render

          value(view.log).must_include([:display_summary, "first paragraph"])
        end

        it "renders 'no comments' if the post has no comments" do
          post.comments = []

          presenter.render

          value(view.log).must_include([:display_comments, "no comments"])
        end

        it "renders 'one comment' if the post has one comment" do
          post.comments = [Projections::Comment.new]

          presenter.render

          value(view.log).must_include([:display_comments, "one comment"])
        end

        it "renders 'N comments' if the post has N comments" do
          post.comments = [Projections::Comment.new,
                           Projections::Comment.new]

          presenter.render

          value(view.log).must_include([:display_comments, "2 comments"])
        end
      end
    end
  end
end
