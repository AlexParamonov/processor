module Processor
  module Subroutine
    class Name < ::SimpleDelegator
      def name
        # underscore a class name
        __getobj__.class.name.to_s.
          gsub(/::/, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end
    end
  end
end
