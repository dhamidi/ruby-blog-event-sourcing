module Blog::Values
  class Malformed < StandardError
    attr_reader :type, :value

    def initialize(type, value)
      @type = type
      @value = value
    end

    def to_s
      "malformed #{@type.name} #{value.inspect}"
    end
  end

  class Text
    def initialize
      @value = ''
    end

    def parse(value)
      @value = value.to_s.strip
      self
    end

    def to_s
      @value
    end
  end

  class Time
    def initialize
      @value = nil
    end

    def from_time(time)
      @value = time
      self
    end

    def parse(value)
      @value = Time.parse(value.to_s.strip)
      self
    end

    def to_s
      @value.iso8601
    end
  end

  class Email
    def initialize
      @value = nil
    end

    def parse(value)
      @value = value.to_s.strip
      raise Malformed.new(Email, value) unless @value =~ /@/

      self
    end

    def to_s
      @value
    end
  end

  class PostId
    def initialize
      @value = nil
    end

    def parse(value)
      if value =~ %r{^posts/[a-z][-a-z0-9]*$}
        @value = value.to_s.strip
      else
        raise Malformed.new(PostId, value)
      end

      self
    end

    def to_s
      @value
    end
  end

  class Integer
    def initialize
      @value = nil
    end

    def parse(value)
      value = value.to_s.strip
      if value =~ /[1-9][0-9]*/
        @value = value.to_i
      else
        raise Malformed.new(Integer, value)
      end
    end

    def to_s
      @value.to_s
    end

    def to_i
      @value
    end
  end
end
