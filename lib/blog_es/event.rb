class Blog::Event
  def with(name, payload)
    @name = name
    @payload = payload

    self
  end

  def name; @name; end

  def receiver_id
    @payload.fetch(:id).to_s
  end

  def to_h
    @payload.merge(:event_name => @name)
  end

  def from_h(hash)
    @name = hash.delete(:event_name)
    @payload = hash

    self
  end
end
