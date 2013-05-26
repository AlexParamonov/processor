require_relative 'null_processor'

module Processor
  module Data
    class CsvProcessor < NullProcessor
      def initialize(file, csv_options = {})
        @file = file
        @separator = separator
        @csv_options = {
          col_sep: ";",
          headers: true,
        }.merge csv_options
      end

      def process(row)
        raise NotImplementedError
      end

      def records
        Enumerator.new do |result|
          ::CSV.foreach(file, csv_options) do |record|
            result << record
          end
        end
      end

      def total_records
        @total_records ||= File.new(file).readlines.size
      end

      private
      attr_reader :file, :separator, :csv_options

      def fetch_field(field_name, row)
        row[field_name].to_s.strip
      end
    end
  end
end
