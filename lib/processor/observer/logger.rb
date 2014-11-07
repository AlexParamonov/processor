require 'logger'
require 'ostruct'
require_relative 'null_observer'
require 'processor/subroutine/name'
require 'processor/logger_messages'

module Processor
  module Observer
    class Logger < NullObserver
      def initialize(logger = nil, options = {})
        if logger.is_a? Hash
          @log_level = logger.fetch :level, ::Logger::INFO
        else
          @logger_source = logger
        end

        @messages = options.fetch :messages, nil
        @messages = OpenStruct.new @messages if @messages.is_a? Hash


        super options
      end

      def after_start(result)
        logger.info "Processing of #{processor_name} started."
        messenger.info messages.initialized
      end

      def before_process(record)
        logger.debug "Record #{id_for record} is going to be processed"
      end

      def after_process(result, record)
        logger.info "Processed #{id_for record}: #{result}"
      end

      def after_finalize(result)
        logger.info "Processing of #{processor_name} finished."
        messenger.message messages.finished
      end

      def after_record_error(result, record, exception)
        logger.error "Error processing #{id_for record}: #{exception.inspect}"
      end

      def after_error(result, exception)
        logger.fatal "Processing #{processor_name} FAILED: #{exception.backtrace}"
      end

      def logger
        @logger ||= begin
        if @logger_source.is_a? Proc
            @logger_source.call processor_name
          else
            @logger_source or ::Logger.new(create_log_filename(processor_name)).tap do |logger|
              logger.level = log_level
            end
          end
        end
      end

      private

      def log_level
        @log_level ||= ::Logger::INFO
      end

      def messages
        @messages ||= LoggerMessages.new logger
      end

      def processor_name
        @processor_name ||=
          begin
            @processor = Subroutine::Name.new processor unless processor.respond_to? :name
            processor.name
          end
      end

      def create_log_filename(processor_name)
        unless File.directory? log_directory
          FileUtils.mkdir log_directory
          messenger.warn "Created new directory for logs: #{File.absolute_path log_directory}"
        end

        @log_file_name = "#{log_directory}/#{processor_name}_on_#{current_time_string}.log"
      end

      def log_directory
        "log"
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
