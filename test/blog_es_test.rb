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
end
