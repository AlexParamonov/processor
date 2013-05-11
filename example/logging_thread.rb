require 'processor/thread'
require 'processor/observer/logger'

module Processor
  module Example
    class LoggingThread < Processor::Thread
      def initialize(processor)
        super(
          processor,
          Processor::Observer::Logger.new
        )
      end
    end
  end
end
