require 'time'
require 'json'

require "blog_es/version"

module Blog
end

require 'blog_es/command'
require 'blog_es/errors'
require 'blog_es/event'
require 'blog_es/events_on_disk'
require 'blog_es/in_memory_publisher'
require 'blog_es/json_serializer'
require 'blog_es/values'
require 'blog_es/post'

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

    def initialize(event_store:, event_publisher:)
      @event_store = event_store
      @event_publisher = event_publisher
    end

    def handle_command(command)
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
      @event_store.store(event)
      @event_publisher.publish_event(event)
    end

    def forward(aggregate)
      @event_store.replay(aggregate.id, aggregate)
    end
  end
end
