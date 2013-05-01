require_relative 'null_observer'

module Processor
  module Observer
    class ProgressBar < NullObserver
      def found(count)
        @progress_bar = ::ProgressBar.new("Records", count)
      end

      def before_proccessing(record)
        progress_bar.inc
      end

      def finalize(runner)
        progress_bar.finish
      end

      private
      attr_reader :progress_bar
    end
  end
end
