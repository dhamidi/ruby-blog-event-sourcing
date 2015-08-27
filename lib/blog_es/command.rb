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
    params.to_h.each do |(field, value)|
      param = @fields[field.to_sym]
      next unless param
      begin
        @values[field.to_sym] = param.new.parse(value)
      rescue Blog::Values::Malformed => e
        @errors.add(field, :malformed)
      end
    end

    self
  end

  def get(field, &not_found)
    @values.fetch(field.to_sym, &not_found)
  end

  def to_s
    "#{@name}@#{receiver.id}"
  end
end
