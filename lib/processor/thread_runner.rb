require_relative "events_registrator"

module Processor
  class ThreadRunner
    def initialize(*observers)
      @observers = observers
    end

    # This method is thread-safe. But not observers.
    # Consider creating new runner for a thread or use thread safe observers
    def run(processor)
      events = events_registrator
      events.register :processing_started, processor

      records_ran = 0
      until processor.done?(records = processor.fetch_records)
        threads = []
        begin
          records.each do |record|
            recursion_preventer processor do
              records_ran += 1
            end

            threads << Thread.new(processor, record) do |thread_data_processor, thread_record|
              begin
                events.register :before_record_processing, thread_record

                result = thread_data_processor.process(thread_record)

                events.register :after_record_processing, thread_record, result
              rescue RuntimeError => exception
                events.register :record_processing_error, thread_record, exception
              end
            end
          end
        ensure # join already created threads even if recursion was detected
          threads.each(&:join)
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
