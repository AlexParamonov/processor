require_relative "runner"

module Processor
  class ThreadRunner < Runner
    def run
      super &method(:process_records)
    end

    def process_records(records, events, recursion_preventer)
      threads = []
      begin
        records.each do |record|
          recursion_preventer.call
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
  end
end
