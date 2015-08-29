$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'blog_es'

require 'minitest/autorun'

class TestCase
  def initialize(receiver)
    @given = []
    @receiver = receiver
  end

  def given(*event)
    @given.push(*event)
    self
  end

  def when(command)
    @command = command
    self
  end

  def then(&block)
    @command.acknowledge!
    @given.each { |event| @receiver.handle_event(event) }
    yield @receiver.handle_command(@command)
    self
  end
end
