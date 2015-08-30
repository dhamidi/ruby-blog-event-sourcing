require 'pstore'
require 'fileutils'

module Blog
  class OnDiskKVStore
    def initialize(filename)
      @store = PStore.new(filename)
    end

    def set(key, value)
      @store.transaction do
        @store[key.to_sym] = value
      end
    end

    def get(key)
      @store.transaction(true) do
        begin
          next @store.fetch(key.to_sym)
        rescue PStore::Error
          raise KeyError.new("key not found: #{key.to_sym.inspect}")
        end
      end
    end

    def del(key)
      @store.transaction do
        @store.delete(key.to_sym)
      end
    end

    def clear!
      begin
        FileUtils.rm(@store.path)
      rescue Errno::ENOENT
      end
    end
  end
end
