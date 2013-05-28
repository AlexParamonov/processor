require "logger"

module Processor
  class LoggerMessages < SimpleDelegator
    def initialize(logger)
      log_device = fetch_log_device logger
      messages = case log_device
                 when File::NULL then NullMessages.new
                 when String then FileMessages.new log_device
                 when File then FileMessages.new log_device.path
                 when IO then IoMessages.new
                 else NullMessages.new
                 end

      super messages
    end

    class NullMessages
      def initialize(filename = "")
        @filename = filename
      end
      def initialized; "" end
      def finished; "" end
      private
      attr_reader :filename
    end

    class IoMessages < NullMessages
      def initialized
        "Proggress will be streaming to provided IO object"
      end
    end

    class FileMessages < NullMessages
      def initialized
        <<-MESSAGE
          Proggress will be saved to the log file. Run
          tail -f #{filename}
          to see log in realtime
          MESSAGE
      end

      def finished
        "Log file saved to #{filename}"
      end
    end

    private
    def fetch_log_device logger
      return unless logger.is_a? ::Logger
      log_dev = logger.instance_variable_get "@logdev"
      log_dev.filename or log_dev.dev
    end
  end
end
