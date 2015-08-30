require 'test_helper'

module Blog
  module Presenter
    class PresenterTest < Minitest::Spec
      class DummyView
        def initialize
          @log = []
        end

        def display(key, value)
          @log.push [:"display_#{key}", value.to_s]
        end

        def link(key, href)
          @log.push [:"link_#{key}", href.to_s]
        end

        def log
          @log
        end
      end

      def make_post(id:,title:,body:,comments:)
        subject = Projections::Post.new
        subject.title = title
        subject.body = body
        subject.comments = comments.times.map { Projections::Comment.new }
        subject.links = Projections::Links.new
        subject.links.add(:self, "/#{id}")
        subject.links.add(:comment, "/#{id}/actions/comment")
        subject.links.add(:pending_comments, "/#{id}/pending-comments")
        subject.links.add(:accept_comment, "/#{id}/actions/accept-comment")
        subject.links.add(:reject_comment, "/#{id}/actions/reject-comment")
        subject.links.add(:edit, "/#{id}/actions/actions/edit")
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

      describe PostDetail do
        let(:post) do
          make_post(id: 'the-post',
                    title: "post title",
                    body: "post body",
                    comments: 0)
        end

        let(:view) do
          DummyView.new
        end

        let(:views) do
          View::Views.new.add :post_detail_no_comments do
            DummyView.new.tap do |v|
              def v.to_s
                "no comments"
              end
            end
          end.add :post_detail_comment do
            DummyView.new.tap do |v|
              def v.to_s
                "comment"
              end
            end
          end
        end

        let(:presenter) do
          PostDetail.new(view, post, views)
        end

        it "renders the post's title" do
          presenter.render

          value(view.log).must_include([:display_title, "post title"])
        end

        it "renders the post's body" do
          presenter.render

          value(view.log).must_include([:display_body, "post body"])
        end

        it "renders 'no comments' if the post has 0 comments" do
          presenter.render

          value(view.log).must_include([:display_comments, 'no comments'])
        end

        it "renders all comments if the post has more than 0 comments" do
          views.add :post_detail_comment do
            View::HTML.new '%{author} %{body}'
          end
          post.comments = [
            Projections::Comment.new.tap do |c|
              c.author = Projections::Author.new('author', '')
              c.body = "comment"
            end
          ]

          presenter.render
          value(view.log).must_include([:display_comments, 'author comment'])
        end

        it "renders a link to commenting on the post" do
          presenter.render
          value(view.log).must_include([:display_comment_url, post.links.rel(:comment)])
        end
      end

      describe PendingComments do
        let(:post) do
          make_post(id: 'the-post',
                    title: "post title",
                    body: "first paragraph\n\nsecond paragraph",
                    comments: 0)
        end

        let(:view) do
          DummyView.new
        end

        let(:views) do
          Blog::View::Views.new.add(:pending_comment) do
            View::HTML.new '%{comment_id} '
          end.add(:no_pending_comments) do
            View::HTML.new 'no pending comments'
          end.add(:pending_comments) do
            View::HTML.new '%{comments}'
          end
        end

        let(:presenter) do
          PendingComments.new(view, post, views)
        end

        it "links the post's title to the post" do
          presenter.render
          value(view.log).must_include([:display_post_title, post.title])
          value(view.log).must_include([:link_post_title, post.links.rel(:self)])
        end

        it "renders all pending comments on the post" do
          author = Projections::Author.new('author-name', 'author-email')
          now = Time.now
          post.pending_comments = [
            Projections::Comment.new(1, 'body', author, now),
            Projections::Comment.new(2, 'body', author, now),
          ]

          presenter.render

          value(view.log).must_include([:display_comments, '1 2 '])
        end

        it "renders a note if there are no pending comments" do
          presenter.render
          value(view.log).must_include([:display_comments, 'no pending comments'])
        end
      end

      describe AdminIndex do
        let(:posts) do
          [
            make_post(id: 'first', title: 'first', body: 'first', comments: 0),
            make_post(id: 'second', title: 'second', body: 'second', comments: 0),
          ]
        end

        let(:view) do
          DummyView.new
        end

        it "renders all posts" do
          posts_on_index = []
          views = View::Views.new.add :admin_post_on_index do
            view = DummyView.new
            posts_on_index.push view
            view
          end

          AdminIndex.new(view, posts, views).render

          value(posts_on_index.length).must_equal posts.length
        end
      end

      describe AdminPostOnIndex do
        let(:post) do
          make_post(id: 'first', title: 'first', body: 'first', comments: 0)
        end

        let(:view) do
          DummyView.new
        end

        let(:presenter) do
          AdminPostOnIndex.new(view, post)
        end

        it "renders the post title" do
          presenter.render
          value(view.log).must_include [:display_post_title, post.title]
        end

        it "renders the count of pending comments" do
          presenter.render
          value(view.log).must_include [:display_pending_comment_count, "0 pending comments"]
        end

        it "links to the pending comments" do
          presenter.render
          value(view.log).must_include [:link_pending_comment_count, post.links.rel(:pending_comments)]
        end

        it "links to the edit page" do
          presenter.render
          value(view.log).must_include [:link_action_edit, post.links.rel(:edit)]
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
