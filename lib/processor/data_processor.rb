module Processor
  class DataProcessor
    def done?(records)
      records.count < 1
    end

    def process(record)
      raise NotImplementedError
    end

    def fetch_records
      raise NotImplementedError
    end

    def total_records
      raise NotImplementedError
    end

    def name
      # underscore a class name
      self.class.name.to_s.
        gsub(/::/, '_').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
    end
  end
end
