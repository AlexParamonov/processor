module Processor
  class Statistic
    extend Forwardable
    def_delegators :data_processor, :total_records

    def initialize(data_processor)
      @data_processor = data_processor
    end

    def remaining_records_count
      [ total_records - processed_records_count, 0 ].max
    end

    def processed_records_count
      @processed_records_count ||= 0
    end

    def record_processed
      @processed_records_count = processed_records_count + 1
    end

    private
    attr_reader :data_processor
  end
end
