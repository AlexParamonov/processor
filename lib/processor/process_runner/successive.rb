require_relative "threads"

module Processor
  module ProcessRunner
    class Successive < Threads
      private
      def new_thread(processor, record, &block)
        block.call processor, record
      end
    end
  end
end
