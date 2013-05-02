require 'processor/observer/null_observer'
require 'progressbar'

module Processor
  module Example
    module Observer
      class ProgressBar < Processor::Observer::NullObserver
        def processing_started
          @progress_bar = ::ProgressBar.new("Records", processor.total_records)
          messenger.debug "Initialized ProgressBar with #{processor.total_records} records"
        end

        def before_record_processing(record)
          progress_bar.inc
        end

        def processing_finished
          progress_bar.finish
        end

        private
        attr_reader :progress_bar
      end
    end
  end
end
