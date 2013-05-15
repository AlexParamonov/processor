require_relative 'null_processor'

module Processor
  module Data
    class ArrayProcessor < NullProcessor
      def records
        raise NotImplementedError
      end
    end
  end
end
