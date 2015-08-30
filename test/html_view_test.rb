require 'test_helper'
require 'view_test'

module Blog
  module View
    describe HTML do
      include ::ViewTest
      let(:view) { HTML.new('') }

      it "displays values" do
        view = HTML.new '<p>Some %{text}</p>'
        view.display :text, "text"
        value(view.to_s).must_equal "<p>Some text</p>"
      end

      it "encodes ampersands in URLs" do
        view = HTML.new '<a href="%{url}">A link</a>'
        view.display :url, "/search?q=foo&sort=desc"
        value(view.to_s).must_equal '<a href="/search?q=foo&amp;sort=desc">A link</a>'
      end

      it "renders links" do
        view = HTML.new '<p>This is a %{placeholder}</p>'
        view.display :placeholder, "sentence"
        view.link :placeholder, "#"
        value(view.to_s).must_equal %q{<p>This is a <a href="#">sentence</a></p>}
      end
    end
  end
end
