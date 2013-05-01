require_relative 'null_observer'
require 'logger'

module Processor
  module Observer
    class Logger < NullObserver
      def initialize(logger = nil)
        @logger = logger
      end

      def prepare(runner)
        @runner = runner
        logger.info "Processing of #{runner.name} started."

        message = <<-MESSAGE.strip_heredoc
          Proggress will be saved to the log file. Run
          tail -f #{log_file_name}
          to see log in realtime
        MESSAGE
        runner.message message, self.class.name if log_file_name.present?
      end

      def after_proccessing(record, result)
        logger.info "Successfully processed #{id_for record}: #{result}"
      end

      def finalize(runner)
        logger.info "Processing of #{runner.name} finished."
        runner.message "Log file saved to #{log_file_name}", self.class.name if log_file_name.present?
      end

      def record_processing_error(record, exception)
        logger.error "Error processing #{id_for record}: #{exception}"
      end

      def processing_error(runner, exception)
        logger.fatal "Processing #{runner.name} failed: #{exception}"
      end

      private
      attr_reader :runner, :log_file_name

      def logger
        @logger ||= ::Logger.new(create_log_filename)
      end

      def create_log_filename
        @log_file_name = "log/#{Rails.env}_#{runner.name}_on_#{current_time}.log"
      end

      def current_time
        Time.current.strftime "%Y-%m-%d_%H%M%S_UTC"
      end

      def id_for record
        record.respond_to?(:uid) ? record.uid : record["uid"]
      end
    end
  end
end
