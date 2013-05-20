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
        logger.info "Processing of #{processor.name} started."

        message = <<-MESSAGE
          Proggress will be saved to the log file. Run
          tail -f #{log_file_name}
          to see log in realtime
        MESSAGE

        messenger.info message if use_log_file?
      end

      def before_record_processing(record)
        logger.debug "Record #{id_for record} is going to be processed"
      end

      def after_record_processing(record, result)
        logger.info "Processed #{id_for record}: #{result}"
      end

      def processing_finished(processor)
        logger.info "Processing of #{processor.name} finished."
        messenger.info "Log file saved to #{log_file_name}" if use_log_file?
      end

      def record_processing_error(record, exception)
        logger.error "Error processing #{id_for record}: #{exception}"
      end

      def processing_error(processor, exception)
        logger.fatal "Processing #{processor.name} FAILED: #{exception.backtrace}"
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
        messenger.debug "Observer initialized with logger #{@logger}"
      end

      def create_log_filename(processor_name)
        FileUtils.mkdir log_directory unless File.directory? log_directory
        @log_file_name = "#{log_directory}/#{processor_name}_on_#{current_time_string}.log"
      end

      def log_directory
        "log"
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

        record.to_s.strip
      end
    end
  end
end
