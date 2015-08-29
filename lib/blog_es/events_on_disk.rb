class Blog::EventsOnDisk
  def initialize(filename, serializer)
    @filename = filename
    @serializer = serializer
  end

  def store(event)
    File.open(@filename, 'a') do |f|
      f.write @serializer.serialize(event.to_h)
      f.write "\n"
    end
  end

  def replay(stream_id, handler)
    begin
      File.open(@filename, 'r').each_line do |line|
        params = @serializer.deserialize(line)
        event = Blog::Event.new.from_h(params)
        if (stream_id == event.receiver_id) || stream_id == :all
          handler.handle_event(event)
        end
      end
    rescue Errno::ENOENT
    end
  end
end
