class Blog::Command
  class NoReceiver < StandardError; end

  def initialize(name, fields, receiver_class)
    @name = name.to_sym
    @fields = fields.to_h
    @values = {}
    @receiver_class = receiver_class
    @receiver = nil
    @errors = Blog::Errors.new
  end

  def name; @name; end
  def errors; @errors; end

  def receiver
    begin
      @receiver = @receiver_class.new(get(:id).to_s) unless @receiver
    rescue KeyError
      raise NoReceiver.new(self)
    end
    @receiver
  end

  def acknowledge!
    @values[:now] = Blog::Values::Time.new.from_time(Time.now)
  end

  def fill(params)
    @values = {}
    @errors = Blog::Errors.new
    @fields.to_h.each do |(field, param)|
      begin
        value = params.fetch(field.to_sym)
        @values[field.to_sym] = param.new.parse(value)
      rescue Blog::Values::Malformed => e
        @errors.add(field, :malformed)
      rescue KeyError => e
        @errors.add(field, :required)
      end
    end

    self
  end

  def valid?
    @errors.empty?
  end

  def get(field, &not_found)
    @values.fetch(field.to_sym, &not_found)
  end

  def to_s
    "#{@name}@#{receiver.id}"
  end
end
