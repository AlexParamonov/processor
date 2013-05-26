require_relative 'counter'

module Processor
  module Subroutine
    class Recursion < ::SimpleDelegator
      def initialize(processor)
        # recursion depends on counter subroutine
        processor = Counter.new(processor) unless processor.respond_to? :processed_records_count

        super processor
      end

      def process(*)
        recursion_preventer
        super
      end

      private
      def recursion_preventer
        raise Exception, "Processing fall into recursion. Check logs." if processed_records_count >= max_records_to_process
      end

      def max_records_to_process
        @max_records_to_process ||= (total_records * 1.1).round + 10
      end
    end
  end
end
