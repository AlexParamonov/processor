require_relative 'null_processor'

module Processor
  class BatchProcessor < NullProcessor
    def records
      Enumerator.new do |result|
        query.each_slice(batch_size) do |records|
          records.each do |record|
            result << record
          end
        end
      end
    end

    def total_records
      query.count
    end

    def query
      raise NotImplementedError
    end

    private
    def batch_size
      10
    end
  end
end
