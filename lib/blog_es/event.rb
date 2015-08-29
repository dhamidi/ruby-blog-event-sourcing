class Blog::Event
  def with(name, payload)
    @name = name
    @payload = payload
    @occurred_on = nil
    self
  end

  def name; @name; end
  def occurred_on; @occurred_on; end

  def acknowledge!(time)
    @occurred_on = time

    self
  end

  def receiver_id
    @payload.fetch(:id).to_s
  end

  def ==(other)
    return false unless other.is_a?(self.class)
    return name == other.name && @payload == other.instance_variable_get(:"@payload")
  end

  def get(key)
    @payload[key.to_sym]
  end

  def to_h
    @payload.merge(:event_name => @name, :occurred_on => @occurred_on)
  end

  def from_h(hash)
    @name = hash.delete(:event_name).to_sym
    @occurred_on = hash.delete(:occurred_on)
    @payload = hash

    self
  end
end
