require_relative "batch_processor"

module Processor
  module Data
    class SolrPagesProcessor < BatchProcessor
      def process(record)
        raise NotImplementedError
      end

      def query(requested_page)
        raise NotImplementedError
      end

      def fetch_batch
        query(next_page).results
      end

      def total_records
        @total_records ||= query(1).total
      end

      private
      def next_page
        @page ||= 0
        @page += 1
      end
    end
  end
end

