require 'test_helper'

module KVStoreTest
  define_method :"test_raises a KeyError when the key does not exist" do
         begin
           store.get(:does_not_exist)
         rescue StandardError => e
           value(e).must_be_instance_of(KeyError)
         end
       end

  define_method :"test_get fetches stored key" do
         store.set(:foo, "bar")
         value(store.get(:foo)).must_equal "bar"
       end

  define_method :"test_del removes key" do
         store.set(:foo, "bar")
         store.del(:foo)
         begin
           value(store.get(:foo)).must_equal nil
         rescue StandardError => e
           value(e).must_be_instance_of(KeyError)
         end
       end
end
