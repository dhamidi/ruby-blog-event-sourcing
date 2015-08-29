class Blog::InMemoryKVStore
  def initialize
    @data = {}
  end

  def set(key, value)
    @data[key.to_sym] = value
    self
  end

  def get(key)
    @data.fetch(key.to_sym)
  end

  def del(key)
    @data.delete(key.to_sym)
    self
  end
end
