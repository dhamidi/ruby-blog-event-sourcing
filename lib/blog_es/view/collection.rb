module Blog
  module View
    class Collection
      def initialize(views, separator: '')
        @views = views
        @separator = separator
      end

      def to_s
        @views.map(&:to_s).join(@separator)
      end

      def to_html
        @views.map do |view|
          begin
            view.to_html
          rescue NoMethodError
            view.to_s
          end
        end.join(@separator)
      end
    end
  end
end
