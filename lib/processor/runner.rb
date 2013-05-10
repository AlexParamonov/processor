require_relative "events_registrator"

module Processor
  class Runner
    def initialize(processor, *observers)
      @processor = processor
      @events = EventsRegistrator.new observers
    end

    def run
      events.register :processing_started, processor
      until processor.done?(records = processor.fetch_records)
        yield records, events, method(:recursion_preventer) if block_given?
      end

      events.register :processing_finished, processor
    rescue Exception => exception
      events.register :processing_error, processor, exception
      raise exception
    end

    protected
    attr_writer :counter
    def counter
      @counter ||= 0
    end

    private
    attr_reader :events, :processor
    def recursion_preventer
      self.counter += 1
      raise Exception, "Processing fall into recursion. Check logs." if self.counter > max_records_to_process
    end

    def max_records_to_process
      (processor.total_records * 1.1).round + 10
    end
  end
end
