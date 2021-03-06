require 'test_helper'

module Blog::Projections
  class Test < Minitest::Spec
    describe Posts do
      describe "find" do
        it "returns a single post" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          )

          post = projection.find('posts/a-post')

          value(post.id).must_equal('posts/a-post')
        end
      end

      describe "recent" do
        it "returns newer posts first" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/another-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now + 60,
                                     })
          )

          expected = [
            store.get('posts/another-post'),
            store.get('posts/a-post'),
          ]

          value(projection.recent).must_equal(expected)
        end
      end

      describe "all" do
        it "returns all posts" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/another-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          )
          expected = [store.get('posts/a-post'), store.get('posts/another-post')]
          value(projection.all).must_equal expected
        end

      end

      describe "on post_edited" do
        it "updates the post title" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_edited,
                                       id: 'posts/a-post',
                                       title: "new-post-title",
                                       body: "new-post-body",
                                       occurred_on: now,
                                     })
          )

          post = store.get('posts/a-post')
          value(post.title).must_equal('new-post-title')
          value(post.body).must_equal('new-post-body')
        end
      end
      describe "on post_written" do
        it "stores a post" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          )

          post = store.get('posts/a-post')
          value(post.title).must_equal 'post-title'
          value(post.body).must_equal 'post-body'
          value(post.written_at).must_equal now
          value(post.comment_count).must_equal 0
          value(post.links).must_equal Links.new.
                                        add(:self, '/posts/a-post').
                                        add(:comment, '/posts/a-post/actions/comment').
                                        add(:pending_comments, '/admin/posts/a-post/pending-comments').
                                        add(:accept_comment, '/admin/posts/a-post/actions/accept-comment').
                                        add(:reject_comment, '/admin/posts/a-post/actions/reject-comment').
                                        add(:edit, '/admin/posts/a-post/actions/edit')
        end

        it "adds the post to the index" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/another-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          )

          index = projection.index
          value(index).must_equal ['posts/a-post', 'posts/another-post']
        end
      end

      describe "on post_commented" do
        it "adds a pending comment" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          )
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_commented,
                                       occurred_on: now,
                                       id: 'posts/a-post',
                                       comment_id: 1,
                                       body: "first comment",
                                       email: "foo@example.com",
                                       name: "Comment author",
                                     })
          )

          post = store.get('posts/a-post')
          comment = Comment.new.tap do |c|
            c.id = 1
            c.body = "first comment"
            c.author = Author.new("Comment author", "foo@example.com")
            c.written_at = now
          end
          value(post.pending_comments).must_equal [comment]
        end
      end

      describe "on post_comment_accepted" do
        it "moves comment from pending to comments" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_commented,
                                       occurred_on: now,
                                       id: 'posts/a-post',
                                       comment_id: 1,
                                       body: "first comment",
                                       email: "foo@example.com",
                                       name: "Comment author",
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_comment_accepted,
                                       occurred_on: now,
                                       id: 'posts/a-post',
                                       comment_id: 1,
                                     })
          )

          post = store.get('posts/a-post')
          comment = Comment.new.tap do |c|
            c.id = 1
            c.body = "first comment"
            c.author = Author.new("Comment author", "foo@example.com")
            c.written_at = now
            c.accepted_at = now
          end
          value(post.comments).must_equal [comment]
        end
      end

      describe "on post_comment_rejected" do
        it "removes comment from pending" do
          store = ::Blog::InMemoryKVStore.new
          now = Time.now
          projection = Posts.new(store)
          projection.handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_written,
                                       id: 'posts/a-post',
                                       title: "post-title",
                                       body: "post-body",
                                       occurred_on: now,
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_commented,
                                       occurred_on: now,
                                       id: 'posts/a-post',
                                       comment_id: 1,
                                       body: "first comment",
                                       email: "foo@example.com",
                                       name: "Comment author",
                                     })
          ).handle_event(
            ::Blog::Event.new.from_h({
                                       event_name: :post_comment_rejected,
                                       occurred_on: now,
                                       id: 'posts/a-post',
                                       comment_id: 1,
                                     })
          )

          post = store.get('posts/a-post')
          value(post.comments).must_equal []
          value(post.pending_comments).must_equal []
        end
      end
    end
  end
end
