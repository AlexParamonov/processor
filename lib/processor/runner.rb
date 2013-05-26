require_relative "events_registrator"

module Processor
  class Runner
    def initialize(processor, events_registrator)
      @processor = processor
      @events = events_registrator
    end

    def run(process_runner)
      processor.start
      events.register :processing_started, processor

      process_runner.call processor, events

      processor.finish
      events.register :processing_finished, processor

    rescue Exception => exception
      processor.error exception
      events.register :processing_error, processor, exception
      raise exception

    ensure
      processor.finalize
      events.register :processing_finalized, processor

    end

    private
    attr_reader :events, :processor
  end
end
