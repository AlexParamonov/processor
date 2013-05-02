require 'processor/thread_runner'
require 'processor/observer/logger'

module Processor
  module Example
    class ExampleRunner < ThreadRunner
      def initialize
        # Logger could be a lambda
        # logger = -> name do
        #   ::Logger.new("log/debug_#{name}_daily.log", "daily").tap do |logger|
        #     logger.datetime_format = "%H:%M:%S"
        #     logger.level = ::Logger::DEBUG
        #   end
        # end

        # logger could be an instance of Ruby Logger
        logger = ::Logger.new(STDOUT).tap do |logger|
          logger.level = ::Logger::DEBUG
          logger.formatter =  -> _, _, _, msg do
            "log < #{msg}\n"
          end
        end

        # logger could be an instance of Rails Logger
        # logger = Rails.logger
        # Or be nil
        # logger = nil
        # in this case logger will be initialized as Ruby Logger and write to log/name_of_processor_time_stamp.log

        # messenger could be an instance of Ruby Logger
        messenger = ::Logger.new(STDOUT).tap do |logger|
          logger.formatter =  -> _, _, _, msg do
            "message > #{msg}\n"
          end
          logger.level = ::Logger::INFO
        end

        logger_observer = Processor::Observer::Logger.new(logger, messenger: messenger)
        super logger_observer
      end
    end
  end
end