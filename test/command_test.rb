require 'test_helper'

module Blog
  describe Command do
    cmd = Command.new(:test, {
                        id: Values::PostId,
                        email: Values::Email,
                      }, Post)


    it "requires all parameters to be present" do
      expected = {
        id: [:required],
        email: [:required],
      }
      value(cmd.fill({}).errors.to_h).must_equal expected
    end

    it "checks well-formedness of parameters" do
      expected = {
        id: [:malformed],
        email: [:malformed],
      }

      value(cmd.fill({id: 'foo', email: 'bar'}).errors.to_h).must_equal expected
    end
  end
end
