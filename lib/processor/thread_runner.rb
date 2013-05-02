require_relative "events_registrator"

module Processor
  class ThreadRunner
    def initialize(*observer_sources)
      @observer_sources = observer_sources
    end

    # Observers are recreated on each run.
    # This method should be thread-safe.
    def run(processor)
      events = events_registrator(processor)
      events.register :processing_started

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

      events.register :processing_finished
    rescue Exception => exception
      events.register :processing_error, exception
      raise exception
    end

    private
    attr_reader :observer_sources

    def recursion_preventer(processor)
      counter = yield
      raise Exception, "Processing fall into recursion. Check logs." if counter > (processor.total_records * 1.1).round + 10
    end

    def events_registrator(processor)
      EventsRegistrator.new processor, observer_sources
    end
  end
end
