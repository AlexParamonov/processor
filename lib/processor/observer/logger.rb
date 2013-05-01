require_relative 'null_observer'
require 'logger'

module Processor
  module Observer
    class Logger < NullObserver
      def initialize(logger = nil)
        @logger = logger
      end

      def prepare(migration)
        @migration = migration
        logger.info "Migration for #{migration.name} started."

        message = <<-MESSAGE.strip_heredoc
          Proggress will be saved to the log file. Run
          tail -f #{log_file_name}
          to see log in realtime
        MESSAGE
        migration.message message, self.class.name if log_file_name.present?
      end

      def after_proccessing(record, result)
        logger.info "Successfully processed #{id_for record}: #{result}"
      end

      def finalize(migration)
        logger.info "Migration for #{migration.name} finished."
        migration.message "Log file saved to #{log_file_name}", self.class.name if log_file_name.present?
      end

      def record_migration_error(record, exception)
        logger.error "Error migrating #{id_for record}: #{exception}"
      end

      def migration_error(migration, exception)
        logger.fatal "Migration #{migration.name} failed: #{exception}"
      end

      private
      attr_reader :migration, :log_file_name

      def logger
        @logger ||= ::Logger.new(create_log_filename)
      end

      def create_log_filename
        @log_file_name = "log/#{Rails.env}_#{migration.name}_on_#{current_time}.log"
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
