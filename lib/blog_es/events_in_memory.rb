class Blog::EventsInMemory
  attr_reader :events

  def initialize
    @events = []
  end

  def store(event)
    @events << event
  end

  def replay(stream_id, handler)
    @events.each do |event|
      if (stream_id.to_sym == event.receiver_id.to_sym) || stream_id == :all
        handler.handle_event(event)
      end
    end
  end
end
