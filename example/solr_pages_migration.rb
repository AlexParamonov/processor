require 'processor/data_processor'

module Processor
  module Example
    class SolrPagesMigration < DataProcessor
      def done?(records)
        # Optional custom check for migration to be done.
        # Default is
        # records.count < 1
        super
      end

      def process(user)
        user.set_contact_method "Address book"
        user.save!
      end

      def fetch_records
        query(next_page).results
      end

      def total_records
        @total_records ||= query(1).total
      end

      private
      def query(requested_page)
        User.search {
          fulltext "My company"
          paginate page: requested_page, per_page: 10
        }
      end

      def next_page
        @page ||= 0
        @page += 1
      end
    end
  end
end

