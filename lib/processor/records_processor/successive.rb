module Processor
  module RecordsProcessor
    class Successive
      def call(records, processor, events, recursion_preventer)
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
end
