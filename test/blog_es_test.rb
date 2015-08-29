require 'test_helper'

class BlogEsTest < Minitest::Spec
  def test_that_it_has_a_version_number
    refute_nil ::BlogEs::VERSION
  end

  describe "writing a post" do
    it "emits a post_written event" do
      TestCase.new(::Blog::Post.new('posts/a-post')).when(
        Blog::Application::WritePost.fill({
                                            id: 'posts/a-post',
                                            title: 'a title',
                                            body: 'a body',
                                          })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.get(:id), 'posts/a-post')
        assert_equal(result.name.to_sym, :post_written)
      end
    end

    it "fails if the post has been written already" do
      TestCase.new(::Blog::Post.new('posts/a-post')).given(
        ::Blog::Event.new.with(:post_written, {})
      ).when(
        Blog::Application::WritePost.fill({
                                            id: 'posts/a-post',
                                            title: 'a title',
                                            body: 'a body',
                                          })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_includes(result.to_h.fetch(:id, []), :not_unique)
      end
    end
  end

  describe "editing a post" do
    it "emits a :post_edited event" do
      TestCase.new(::Blog::Post.new('posts/a-post')).given(
        ::Blog::Event.new.with(:post_written, {})
      ).when(
        Blog::Application::EditPost.fill({
                                           id: 'posts/a-post',
                                           title: 'a new title',
                                           body: 'a new body',
                                         })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.get(:id), 'posts/a-post')
        assert_equal(result.to_h.values_at(:title, :body), ['a new title', 'a new body'])
      end
    end

    it "returns an error if the post has not been written yet" do
      TestCase.new(::Blog::Post.new('posts/a-post')).when(
        Blog::Application::EditPost.fill({
                                           id: 'posts/a-post',
                                           title: 'a new title',
                                           body: 'a new body',
                                         })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.get(:id), :not_found)
      end
    end
  end

  describe "commenting a post" do
    it "emits a :post_commented event" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).when(
        ::Blog::Application::CommentOnPost.fill({
                                                  id: 'posts/a-post',
                                                  name: "A commenter",
                                                  email: "foo@example.com",
                                                  body: "hello, world",
                                                })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.name, :post_commented)
        assert_equal(result.get(:id), 'posts/a-post')
      end
    end

    it "requires all input parameters to be present" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).when(
        ::Blog::Application::CommentOnPost.fill({
                                                  id: 'posts/a-post',
                                                  name: "",
                                                  email: "",
                                                  body: "",
                                                })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.to_h, {
                       name: [:required],
                       email: [:malformed, :required],
                       body: [:required],
                     })
      end
    end

    it "returns an error if the post has not been written yet" do
      TestCase.new(::Blog::Post.new("posts/a-post")).when(
        ::Blog::Application::CommentOnPost.fill({
                                                  id: 'posts/a-post',
                                                  name: "A commenter",
                                                  email: "foo@example.com",
                                                  body: "hello, world",
                                                })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.to_h, {
                       id: [:not_found],
                     })
      end
    end

    it "assigns consecutive ids to comments, starting from 1" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).given(
        ::Blog::Event.new.with(:post_commented, {})
      ).when(
        ::Blog::Application::CommentOnPost.fill({
                                                  id: 'posts/a-post',
                                                  name: "A commenter",
                                                  email: "foo@example.com",
                                                  body: "hello, world",
                                                })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.to_h[:comment_id], 2)
      end
    end
  end

  describe "accepting a comment" do
    it "returns an error if the post has not been written yet" do
      TestCase.new(::Blog::Post.new("posts/a-post")).when(
        ::Blog::Application::AcceptCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 1,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.get(:id), :not_found)
      end
    end

    it "emits a :post_comment_accepted event" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).given(
        ::Blog::Event.new.with(:post_commented, {comment_id: 1})
      ).when(
        ::Blog::Application::AcceptCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 1,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.get(:id), 'posts/a-post')
        assert_equal(result.name, :post_comment_accepted)
      end
    end

    it "returns :not_found error when the comment does not exist" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).given(
        ::Blog::Event.new.with(:post_commented, {comment_id: 1})
      ).when(
        ::Blog::Application::AcceptCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 100,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.to_h[:comment_id], [:not_found])
      end
    end
  end
  describe "rejecting a comment" do
    it "returns an error if the post has not been written yet" do
      TestCase.new(::Blog::Post.new("posts/a-post")).when(
        ::Blog::Application::RejectCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 1,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.get(:id), :not_found)
      end
    end

    it "emits a :post_comment_rejected event" do
      email = "foo@example.com"
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {})
      ).given(
        ::Blog::Event.new.with(:post_commented, {comment_id: 1, email: email})
      ).when(
        ::Blog::Application::RejectCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 1,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Event, result)
        assert_equal(result.name, :post_comment_rejected)
        assert_equal(result.get(:id), 'posts/a-post')
        assert_equal(result.to_h[:email], email)
      end
    end

    it "returns a not_found error if the comment does not exist" do
      TestCase.new(::Blog::Post.new("posts/a-post")).given(
        ::Blog::Event.new.with(:post_written, {}),
        ::Blog::Event.new.with(:post_commented, {})
      ).when(
        ::Blog::Application::RejectCommentOnPost.fill({
                                                        id: 'posts/a-post',
                                                        comment_id: 100,
                                                      })
      ).then do |result|
        assert_instance_of(::Blog::Errors, result)
        assert_equal(result.to_h[:comment_id], [:not_found])
      end
    end

    it "sends an email stating the reason to the commenter" do
      publisher = ::Blog::InMemoryEventPublisher.new
      store = ::Blog::EventsInMemory.new
      mailer = ::Blog::Mailer::InMemory.new
      app = ::Blog::Application.new(event_store: store,
                                    event_publisher: publisher,
                                    mailer: mailer,
                                 )

      app.handle_event(::Blog::Event.new.with(:post_written, {
                                                id: "posts/a-post",
                                                body: "foo",
                                                title: "bar",
                                              }))
      app.handle_event(::Blog::Event.new.with(:post_commented, {
                                                id: "posts/a-post",
                                                comment_id: 1,
                                                email: "foo@example.com",
                                                body: "bar",
                                              }))
      app.handle_event(::Blog::Event.new.with(:post_comment_rejected, {
                                                comment_id: 1,
                                                email: "foo@example.com",
                                                reason: "spam",
                                              }))
      assert_equal(mailer.messages.length, 1)
      assert_includes(mailer.messages.first.message.body, "spam")
      assert_includes(mailer.messages.first.to, "foo@example.com")
    end
  end

  describe ::Blog::Application do
    def clock(at:)

      the_clock = Object.new
      the_clock.instance_variable_set("@time", at)
      def the_clock.now
        @time
      end

      the_clock
    end

    describe "emit(event)" do
      it "adds a timestamp based on the current clock to the event" do
        publisher = ::Blog::InMemoryEventPublisher.new
        store = ::Blog::EventsInMemory.new
        mailer = ::Blog::Mailer::InMemory.new
        now = clock(at: Time.now)
        app = ::Blog::Application.new(event_store: store,
                                      event_publisher: publisher,
                                      mailer: mailer,
                                      clock: now,
                                     )
        handler = Object.new.tap do |o|
          def o.timestamp; @timestamp; end
          def o.handle_event(event)
            @timestamp = event.occurred_on
          end
        end

        publisher.register(:check_timestamp, handler)

        app.emit ::Blog::Event.new.with(:post_written, {})

        assert_equal(handler.timestamp, now.now)
      end
    end
  end
end
