require_relative 'null_observer'
require 'logger'

module Processor
  module Observer
    class Logger < NullObserver
      def initialize(logger = nil, options = {})
        @logger_source = logger
        super options
      end

      def processing_started(processor)
        initialize_logger(processor)

        message = "Processing of #{processor.name} started."
        logger.info message
        messenger.info message

        message = <<-MESSAGE.gsub(/^\s+/, '')
          Proggress will be saved to the log file. Run
          tail -f #{log_file_name}
          to see log in realtime
          MESSAGE
          messenger.info message if use_log_file?
      end

      def before_record_processing(record)
        message = "Record #{id_for record} is going to be processed"
        logger.debug message
        messenger.debug message
      end

      def after_record_processing(record, result)
        message = "Successfully processed #{id_for record}: #{result}"
        logger.info message
        messenger.debug message
      end

      def processing_finished(processor)
        message = "Processing of #{processor.name} finished."
        logger.info message
        messenger.info message
        messenger.info "Log file saved to #{log_file_name}" if use_log_file?
      end

      def record_processing_error(record, exception)
        message = "Error processing #{id_for record}: #{exception}"
        logger.error message
        messenger.error message
      end

      def processing_error(processor, exception)
        message = "Processing #{processor.name} failed: #{exception}"
        logger.fatal message
        messenger.fatal message
      end

      private
      attr_reader :logger, :log_file_name

      def initialize_logger(processor)
        @logger =
          if @logger_source.is_a? Proc
            @logger_source.call processor.name
          else
            @logger_source or ::Logger.new(create_log_filename(processor.name)).tap do |logger|
              logger.level = ::Logger::INFO
            end
          end
      end

      def create_log_filename(processor_name)
        @log_file_name = "log/#{processor_name}_on_#{current_time_string}.log"
      end

      def use_log_file?
        not log_file_name.nil?
      end

      def current_time_string
        Time.now.gmtime.strftime "%Y-%m-%d_%H%M%S_UTC"
      end

      def id_for record
        [:uid, :id, :to_token, :token, :to_sym].each do |method|
          return record.public_send method if record.respond_to? method
        end

        [:uid, :id, :token, :sym, :UID, :ID, :TOKEN, :SYM].each do |method|
          return record[method] if record.key? method
          return record[method.to_s] if record.key? method.to_s
        end if record.respond_to?(:key?) && record.respond_to?(:[])

        record.to_s
      end
    end
  end
end
