require 'processor/data_processor'

module Processor
  module Example
    class SolrMigration < DataProcessor
      def process(user)
        user.set_contact_method "Address book"
        user.save!
      end

      def fetch_records
        query.results
      end

      def total_records
        @total_records ||= query.total
      end

      private
      # query will return 0 records when all users'll be processed successfully
      def query
        User.search {
          fulltext "My company"
          with :title, "Manager"
          with :contact_method, "Direct contact"
          paginate page: 1, per_page: 10
        }
      end
    end
  end
end
