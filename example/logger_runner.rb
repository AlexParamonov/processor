require 'processor/thread_runner'
require 'processor/observer/logger'

module Processor
  module Example
    class LoggerRunner
      extend Forwardable
      def_delegators :@runner, :run

      def initialize
        @runner = ThreadRunner.new(
          Processor::Observer::Logger.new
        )
      end
    end
  end
end
