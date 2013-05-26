module Processor
  module Data
    class NullProcessor
      def start; end
      def finish; end
      def finalize; end
      def error(exception); end

      def process(record)
        stats.record_processed
      end

      def records
        []
      end

      def stats
        @stats ||= Processor::Statistic.new self
      end

      def total_records
        0
      end

      def name
        # underscore a class name
        self.class.name.to_s.
          gsub(/::/, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end
    end
  end
end
