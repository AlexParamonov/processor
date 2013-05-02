require 'processor/thread_runner'
require 'processor/observer/logger'

module Processor
  module Example
    class DebugRunner < ThreadRunner
      def initialize
        logger = -> name do
          ::Logger.new("log/debug_#{name}_daily.log", "daily").tap do |logger|
            logger.datetime_format = "%H:%M:%S"
            logger.level = ::Logger::DEBUG
          end
        end

        messenger = ::Logger.new(STDOUT).tap do |logger|
          logger.formatter =  -> _, _, _, msg do
            "> #{msg}\n"
          end
          logger.level = ::Logger::DEBUG
        end

        logger_observer = -> processor do
          Processor::Observer::Logger.new(
            processor,
            logger: logger,
            messenger: messenger
          )
        end
        super logger_observer
      end
    end
  end
end
