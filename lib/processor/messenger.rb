require "logger"

module Processor
  class Messenger < SimpleDelegator
    def initialize(level = :info, file = STDOUT, sender = nil)
      @sender = sender
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

    %w[debug info warn error fatal unknown].each do |method_name|
      define_method method_name do |message, *args|
        return if message.nil? || message.empty?
        super message, *args
      end
    end

    def message(*args)
      self.info *args
    end

    private
    attr_reader :sender
    def format_message(severity, datetime, progname, message)
      lines = message.split("\n").map do |line|
        "> %s" % line.gsub(/^\s+/, '')
      end.join("\n")

      message = "\n#{severity} message"
      message << " from #{sender}" if sender
      message << " on #{datetime}"
      message << ":\n#{lines}\n"
    end
  end
end
