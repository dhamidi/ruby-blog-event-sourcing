class Blog::InMemoryEventPublisher
  def initialize
    @event_handlers = []
  end

  def register(name, handler)
    @event_handlers.push [name.to_sym, handler]

    self
  end

  def publish_event(event)
    @event_handlers.each do |(name, handler)|
      handler.handle_event(event)
    end
  end
  alias :handle_event :publish_event
end
