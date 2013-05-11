require 'processor/thread'
require 'processor/observer/logger'

module Processor
  module Example
    class Migrator < Processor::Thread
      def migrate
        messenger.info "Migrator start migrating a records one by one at #{Time.now}"
        run_successive
      end

      def initialize(migration)
        # logger could be an instance of Ruby Logger
        logger1 = ::Logger.new(STDOUT).tap do |logger|
          logger.formatter =  -> _, _, _, msg do
            "debug\t< #{msg}\n"
          end
          logger.level = ::Logger::DEBUG
        end

        # Logger could be a lambda
        # Where "name" is a processor.name
        logger2 = -> name do
          ::Logger.new(STDOUT).tap do |logger|
            logger.formatter =  -> _, _, _, msg do
              "info\t< #{msg}\n"
            end
            logger.level = ::Logger::INFO
          end
        end

        # logger could be an instance of Rails Logger
        # logger = Rails.logger
        # Or be nil
        # logger = nil
        # in this case logger will be initialized as Ruby Logger and write to log/name_of_processor_time_stamp.log

        # You may customize a messenger:
        messenger = ::Logger.new(STDOUT).tap do |logger|
          logger.formatter =  -> _, _, _, msg do
            "message\t> #{msg}\n"
          end
          logger.level = ::Logger::INFO
        end

        stdout_observer1 = Processor::Observer::Logger.new(logger1, messenger: messenger)
        stdout_observer2 = Processor::Observer::Logger.new(logger2, messenger: Logger.new("/dev/null"))
        your_custom_observer1 = Observer::NullObserver.new
        your_custom_observer2 = Observer::NullObserver.new

        super(
          migration,
          stdout_observer1,
          stdout_observer2,
          your_custom_observer1,
          your_custom_observer2,
        )

        @messenger = messenger
      end

      private
      attr_reader :messenger
    end
  end
end
