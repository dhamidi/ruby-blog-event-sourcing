module Blog::Projections
  class Links
    def initialize
      @links = {}
    end

    def add(rel, url)
      @links[rel.to_sym] = url

      self
    end

    def ==(other)
      return @links == other.instance_variable_get("@links")
    end

    def rel(rel)
      @links.fetch(rel.to_sym)
    end
  end
end
