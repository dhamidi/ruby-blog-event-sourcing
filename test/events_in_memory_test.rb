require 'test_helper'
require 'event_store_test'

module Blog
  describe EventsInMemory do
    include EventStoreTest

    let(:event_store) { EventsInMemory.new }
  end
end
