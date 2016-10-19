require_relative "null_processor"

module Processor
  module Data
    class ActiveRecordBatchProcessor < NullProcessor
      attr_reader :source

      def initialize(source:, presenter: -> { Hash.new }, output:, batch_size: 1000)
        @source = source
        @presenter = presenter
        @output = output
        @batch_size = batch_size
      end

      def records
        source.find_each(batch_size: batch_size)
      end

      def process(record)
        output.write presenter.call(record)
        "OK"
      end

      def record_id(record)
        record.id
      end

      def finalize
        output.close
      end

      def total_records
        @total_records ||= source.count
      end

      private
      attr_reader :presenter, :output, :batch_size
    end
  end
end
