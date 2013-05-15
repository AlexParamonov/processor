require_relative 'batch_processor'

module Processor
  module Data
    class CsvProcessor < BatchProcessor
      def initialize(file, separator = ";")
        @file = file
        @separator = separator
      end

      def process(row)
        raise NotImplementedError
      end

      def records
        Enumerator.new do |result|
          ::CSV.foreach(file, :headers => true, :col_sep => separator) do |record|
            result << record
          end
        end
      end

      def total_records
        @total_records ||= File.new(file).readlines.size
      end

      private
      attr_reader :file, :separator

      def fetch_field(field_name, row)
        row[field_name].to_s.strip
      end
    end
  end
end
