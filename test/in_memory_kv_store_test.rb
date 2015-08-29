require 'kv_store_test'

module Blog
  describe InMemoryKVStore do
    include KVStoreTest

    let(:store) { InMemoryKVStore.new }
  end
end
