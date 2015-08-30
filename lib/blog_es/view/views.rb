module Blog
  module View
    class Views
      def initialize
        @views = {}
      end

      def add(key, &constructor)
        @views[key.to_sym] = constructor
      end

      def create(key)
        @views.fetch(key).call
      end
    end
  end
end
