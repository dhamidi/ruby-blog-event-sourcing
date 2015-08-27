require 'test_helper'

class BlogEsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BlogEs::VERSION
  end

  def test_it_emits_an_event_for_writing_a_post
    TestCase.new(::Blog::Post.new('posts/a-post')).when(
      Blog::Application::WritePost.fill({
                                          id: 'posts/a-post',
                                          title: 'a title',
                                          body: 'a body',
                                        })
    ).then do |result|
      assert_instance_of(::Blog::Event, result)
    end
  end

  def test_writing_an_existing_post_fails
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

  def test_it_emits_an_event_for_editing_a_post
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

  def test_edit_post_returns_an_error_if_the_post_has_not_been_written
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
