module Processor
  module Data
    class NullProcessor
      def start; end
      def finish; end
      def finalize; end
      def error(exception); end

      def process(record)
        # do nothing
      end

      def records
        []
      end

      def total_records
        0
      end

    end
  end
end
