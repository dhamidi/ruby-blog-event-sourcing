require 'test_helper'
require 'event_store_test'

module Blog
  describe EventsOnDisk do
    include EventStoreTest

    let(:event_store) { EventsOnDisk.new('events-on-disk-test.log', JSONSerializer) }
    after do
      event_store.remove!
    end
  end
end
