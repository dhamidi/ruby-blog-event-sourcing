require 'test_helper'

module ViewTest
  define_method :"test_responds to :display" do
         begin
           view.display :var, "value"
         rescue NoMethodError, ArgumentError => e
         ensure
           assert_nil e
         end
       end

  define_method :"test_responds to :link" do
         begin
           view.link :foo, "bar"
         rescue NoMethodError, ArgumentError => e
         ensure
           assert_nil e
         end
       end
end
