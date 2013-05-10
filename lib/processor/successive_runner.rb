require_relative "runner"

module Processor
  class SuccessiveRunner < Runner
    def run
      super &method(:process_records)
    end

    private
    def process_records(records, events, recursion_preventer)
      records.each do |record|
        recursion_preventer.call
        begin
          events.register :before_record_processing, record

          result = processor.process(record)

          events.register :after_record_processing, record, result
        rescue RuntimeError => exception
          events.register :record_processing_error, record, exception
        end
      end
    end
  end
end
