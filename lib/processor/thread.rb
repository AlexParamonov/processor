require 'processor/runner'
require 'processor/event_processor'
require 'processor/process_runner/successive'
require 'processor/process_runner/threads'
require 'processor/subroutine/recursion'

module Processor
  class Thread
    def initialize(data_processor, *observers)
      data_processor = Subroutine::Recursion.new(data_processor)

      @runner = Runner.new EventProcessor.new(data_processor, observers)
    end

    def run_as(&process_runner)
      runner.run process_runner
    end

    def run_successive
      runner.run ProcessRunner::Successive.new
    end

    def run_in_threads(number_of_threads = 2)
      runner.run ProcessRunner::Threads.new number_of_threads
    end

    private
    attr_reader :runner
  end
end
