module Blog::Projections
  class Links
    def initialize
      @links = {}
    end

    def []=(rel,url)
      @links[rel.to_sym] = url
    end

    def rel(rel)
      @links.fetch(rel.to_sym)
    end
  end
end
