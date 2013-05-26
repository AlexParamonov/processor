require_relative 'null_processor'

module Processor
  module Data
    class ArrayProcessor < NullProcessor
      def records
        raise NotImplementedError
      end

      def total_records
        @total_records ||= records.count
      end
    end
  end
end
