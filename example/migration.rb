require 'processor/data/array_processor'

module Processor
  module Example
    class Migration < Data::ArrayProcessor
      attr_reader :records

      def initialize(records)
        @records = records
      end

      def process(record)
        record.do_something
        "OK"
      end
    end
  end
end
