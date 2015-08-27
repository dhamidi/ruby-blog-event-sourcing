class Blog::JSONSerializer
  def self.serialize(object)
    JSON.generate(object)
  end

  def self.deserialize(bytes)
    JSON.parse(bytes, symbolize_names: true)
  end
end
