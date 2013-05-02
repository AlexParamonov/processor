require 'processor/data_processor'

module Processor
  module Example
    class Migration < DataProcessor
      attr_reader :records
      def initialize(records)
        @records = records
      end

      def done?(records)
        records.count < 1
      end

      def process(record)
        record.do_something
        "OK"
      end

      def fetch_records
        records.shift(2)
      end

      def total_records
        records.count
      end
    end
  end
end
