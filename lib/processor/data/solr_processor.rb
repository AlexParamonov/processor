require_relative "batch_processor"

module Processor
  module Data
    class SolrProcessor < BatchProcessor
      def process(record)
        super
      end

      def query
        raise NotImplementedError
      end

      def fetch_batch
        query.results
      end

      def total_records
        @total_records ||= query.total
      end
    end
  end
end
