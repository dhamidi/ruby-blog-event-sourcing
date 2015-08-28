class Blog::EventsInMemory
  attr_reader :events

  def initialize
    @events = []
  end

  def store(event)
    @events << event
  end

  def replay(stream_id, handler)
    if (stream_id == event.receiver_id) || stream_id == :all
      handler.handle_event(event)
    end
  end
end
