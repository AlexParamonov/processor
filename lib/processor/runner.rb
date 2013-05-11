require_relative "events_registrator"

module Processor
  class Runner
    def initialize(processor, events_registrator)
      @processor = processor
      @events = events_registrator
    end

    def run(records_processor)
      events.register :processing_started, processor
      until processor.done?(records = processor.fetch_records)
        records_processor.call records, processor, events, method(:recursion_preventer)
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
      @max_records_to_process ||= (processor.total_records * 1.1).round + 10
    end
  end
end
