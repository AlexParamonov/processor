require 'processor/runner'
require 'processor/process_runner/successive'
require 'processor/process_runner/threads'
require 'processor/subroutine/recursion'
require 'processor/subroutine/counter'
require 'processor/subroutine/name'

module Processor
  class Thread
    def initialize(data_processor, *observers)
      [Subroutine::Recursion, Subroutine::Counter, Subroutine::Name].each do |subroutine|
        data_processor = subroutine.new(data_processor)
      end

      @runner = Runner.new data_processor, EventsRegistrator.new(observers)
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
