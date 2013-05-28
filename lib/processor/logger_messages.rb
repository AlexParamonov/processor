require "logger"
require "ostruct"

module Processor
  class LoggerMessages
    NULL = {
      initialized: "",
      finished: "",
    }

    FILE = -> filename {{
      initialized: %Q{
        Proggress will be saved to the log file. Run
        tail -f #{filename}
        to see log in realtime
      },
      finished: "Log file saved to #{filename}"
    }}

    IO = {
      initialized: "Proggress will be streaming to provided IO object",
      finished: "",
    }

    def self.for(logger)
      log_device = fetch_log_device logger
      messages = case log_device
                 when File::NULL then NULL
                 when String then FILE.call log_device
                 when File then FILE.call log_device.path
                 when ::IO then IO
                 else NULL
                 end
      return OpenStruct.new messages
    end

    def self.fetch_log_device logger
      return unless logger.is_a? ::Logger
      log_dev = logger.instance_variable_get "@logdev"
      log_dev.filename or log_dev.dev
    end
  end
end
