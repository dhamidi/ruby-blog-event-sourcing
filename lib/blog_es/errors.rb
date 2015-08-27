class Blog::Errors
  def initialize
    @errors = Hash.new { [] }
  end

  def empty?
    @errors.length == 0
  end

  def add(field, message)
    messages = @errors[field.to_sym]
    messages.push(message)
    @errors[field.to_sym] = messages

    self
  end

  def to_h
    @errors.clone
  end

  def to_s
    @errors.to_s
  end

  def get(field)
    @errors.fetch(field.to_sym, []).first
  end
end
