require_relative "events_registrator"

module Processor
  class SuccessiveRunner
    def initialize(*observers)
      @observers = observers
    end

    def run(processor)
      events = events_registrator
      events.register :processing_started, processor

      records_ran = 0
      until processor.done?(records = processor.fetch_records)
        records.each do |record|
          recursion_preventer processor do
            records_ran += 1
          end
          begin
            events.register :before_record_processing, record

            result = processor.process(record)

            events.register :after_record_processing, record, result
          rescue RuntimeError => exception
            events.register :record_processing_error, record, exception
          end
        end
      end

      events.register :processing_finished, processor
    rescue Exception => exception
      events.register :processing_error, processor, exception
      raise exception
    end

    private
    attr_reader :observers

    def recursion_preventer(processor)
      counter = yield
      raise Exception, "Processing fall into recursion. Check logs." if counter > (processor.total_records * 1.1).round + 10
    end

    def events_registrator
      EventsRegistrator.new observers
    end
  end
end
