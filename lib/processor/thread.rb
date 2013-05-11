require 'processor/runner'
require 'processor/records_processor/successive'
require 'processor/records_processor/threads'

module Processor
  class Thread
    def initialize(data_processor, *observers)
      @runner = Runner.new data_processor, EventsRegistrator.new(observers)
    end

    def run_as(&records_processor)
      runner.run records_processor
    end

    def run_successive
      runner.run RecordsProcessor::Successive.new
    end

    def run_in_threads
      runner.run RecordsProcessor::Threads.new
    end

    private
    attr_reader :runner
  end
end
