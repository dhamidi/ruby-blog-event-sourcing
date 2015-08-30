module Blog
  module View
    class HTML

      def initialize(src)
        @src = src
        @vars = {}
        @placeholders = {}
      end

      def display(name, value)
        if value.respond_to?(:to_html)
          sanitized = value.to_html
        else
          sanitized = html_escape(value.to_s)
        end

        @vars[name.to_sym] = sanitized
        @placeholders[name.to_sym] = @vars[name.to_sym]

        self
      end

      def link(name, href)
        value = @vars.fetch(name.to_sym, '')
        text = "<a href=\"#{html_escape(href)}\">#{value}</a>"
        @placeholders[name.to_sym] = text

        self
      end

      def to_s
        @src % @placeholders
      end

      alias :to_html :to_s

      def html_escape(str)
        str.gsub(/&(?![^;]+;)/, '&amp;').gsub(/[<>"']/) do |match|
          case match
          when '<' then '&lt;'
          when '>' then '&gt;'
          when '"' then '&quot;'
          when "'" then '&apos;'
          end
        end
      end
    end
  end
end
