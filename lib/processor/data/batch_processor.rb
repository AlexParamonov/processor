require_relative 'null_processor'

module Processor
  module Data
    class BatchProcessor < NullProcessor
      def initialize(batch_size = 10)
        @batch_size = batch_size
      end

      def records
        Enumerator.new do |result|
          while (batch = fetch_batch).any?
            batch.each do |record|
              result << record
            end
          end
        end
      end

      def fetch_batch
        @fetcher ||= query.each_slice(batch_size)
        @fetcher.next
      rescue StopIteration
        []
      end

      def total_records
        @total_records ||= query.count
      end

      def query
        raise NotImplementedError
      end

      private
      attr_reader :batch_size
    end
  end
end
