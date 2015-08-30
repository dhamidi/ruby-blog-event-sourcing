require 'time'
require 'json'

require "blog_es/version"

module Blog
end

require 'blog_es/command'
require 'blog_es/errors'
require 'blog_es/event'
require 'blog_es/events_on_disk'
require 'blog_es/events_in_memory'
require 'blog_es/in_memory_publisher'
require 'blog_es/in_memory_kv_store'
require 'blog_es/on_disk_kv_store'
require 'blog_es/mailer/message'
require 'blog_es/mailer/envelope'
require 'blog_es/mailer/in_memory'
require 'blog_es/services/comment_notifier'
require 'blog_es/json_serializer'
require 'blog_es/projections/posts'
require 'blog_es/projections/links'
require 'blog_es/values'
require 'blog_es/post'
require 'blog_es/view/html'
require 'blog_es/view/views'
require 'blog_es/view/collection'
require 'blog_es/presenter/post_on_index'
require 'blog_es/presenter/index'

module Blog
  class Application
    WritePost = Command.new(:write_post, {
                              :id => Values::PostId,
                              :title => Values::Text,
                              :body => Values::Text,
                            }, Post)
    EditPost = Command.new(:edit_post, {
                              :id => Values::PostId,
                              :title => Values::Text,
                              :body => Values::Text,
                            }, Post)
    CommentOnPost = Command.new(:comment_on_post, {
                                  :id => Values::PostId,
                                  :name => Values::Text,
                                  :body => Values::Text,
                                  :email => Values::Email,
                                }, Post)

    AcceptCommentOnPost = Command.new(:accept_comment_on_post, {
                                        :id => Values::PostId,
                                        :comment_id => Values::Integer,
                                      }, Post)
    RejectCommentOnPost = Command.new(:reject_comment_on_post, {
                                        :id => Values::PostId,
                                        :comment_id => Values::Integer,
                                        :reason => Values::Text,
                                      }, Post)

    def initialize(event_store:, event_publisher:, mailer:, clock: Time)
      @event_store = event_store
      @event_publisher = event_publisher
      @mailer = mailer
      @clock = clock
      setup_services
    end

    def handle_command(command)
      return command.errors unless command.valid?
      command.acknowledge!
      begin
        receiver = command.receiver
        forward(receiver)
        result = receiver.handle_command(command)
        if result.is_a?(Event)
          emit(result)
          return :ok
        else
          return result
        end
      rescue Command::NoReceiver
        command.errors
      end
    end

    def emit(event)
      event.acknowledge!(@clock.now)
      @event_store.store(event)
      @event_publisher.publish_event(event)
    end
    alias :handle_event :emit

    def forward(aggregate)
      @event_store.replay(aggregate.id, aggregate)
    end

    private
    def setup_services
      commentNotifier = Services::CommentNotifier.new(mailer: @mailer)

      @event_publisher.register :comment_rejection, commentNotifier
    end
  end
end
