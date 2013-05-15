module Processor
  class NullProcessor
    def process(record)
      # do nothing
    end

    def records
      []
    end

    def total_records
      0
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
