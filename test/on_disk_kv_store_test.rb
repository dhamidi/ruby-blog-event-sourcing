require 'test_helper'

module Blog
  describe OnDiskKVStore do
    include KVStoreTest
    let(:store) { OnDiskKVStore.new('kv_store_test') }
    after do
      store.clear!
    end
  end
end
