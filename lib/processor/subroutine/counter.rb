module Processor
  module Subroutine
    class Counter < ::SimpleDelegator
      def process(*)
        super
        record_processed
      end

      def remaining_records_count
        [ total_records - processed_records_count, 0 ].max
      end

      def processed_records_count
        @processed_records_count ||= 0
      end

      private
      def record_processed
        @processed_records_count = processed_records_count + 1
      end
    end
  end
end
