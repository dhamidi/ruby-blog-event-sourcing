require 'fileutils'

module Blog
  class EventsOnDisk
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
          event = Event.new.from_h(params)
          if (stream_id.to_sym == event.receiver_id.to_sym) || stream_id == :all
            handler.handle_event(event)
          end
        end
      rescue Errno::ENOENT
      end
    end

    def remove!
      begin
        FileUtils.rm @filename
      rescue Errno::ENOENT
      end
    end
  end
end
