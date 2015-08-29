require 'test_helper'

module EventStoreTest
  define_method :"test_store appends event to stream" do
         events = [
           Blog::Event.new.with(:test, {id: 1}),
           Blog::Event.new.with(:test, {id: 2}),
         ]

         events.each do |event|
           event_store.store(event)
         end

         handler = Object.new.tap do |o|
           def o.seen; @seen; end
           def o.handle_event(event)
             @seen ||= []
             @seen << event
           end
         end

         event_store.replay(:all, handler)
         value(handler.seen).must_equal events
       end

  define_method :"test_replay replays events by stream" do
         events = [
           Blog::Event.new.from_h({event_name: :test, id: 'a'}),
           Blog::Event.new.from_h({event_name: :test, id: 'b'}),
         ]

         events.each do |event|
           event_store.store(event)
         end

         handler = Object.new.tap do |o|
           def o.seen; @seen; end
           def o.handle_event(event)
             @seen ||= []
             @seen << event
           end
         end

         event_store.replay(:b, handler)
         value(handler.seen).must_equal [events[1]]
       end
end
