require "logger"

module Processor
  class Messenger < SimpleDelegator
    def initialize(level = :info, file = STDOUT)
      if level == :null
        file = "/dev/null"
        level = :fatal
      end

      log_level = Logger.const_get(level.upcase);

      logger = ::Logger.new(file).tap do |logger|
        logger.formatter = method(:format_message)
        logger.level = log_level
      end

      super logger
    end

    def message(*args)
      self.info *args
    end

    private
    def format_message(severity, datetime, progname, message)
      lines = message.split("\n").map do |line|
        "> %s\n" % line.gsub(/^\s+/, '')
      end.join("\n")

      "#{severity} message on #{datetime}:\n#{lines}\n"
    end
  end
end
