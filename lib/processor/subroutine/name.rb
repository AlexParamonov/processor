require 'delegate'

module Processor
  module Subroutine
    class Name < ::SimpleDelegator
      def name
        return super if __getobj__.respond_to? :name

        # underscore a class name
       @name ||= real_object.class.name.to_s.
          gsub(/::/, '_').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end

      private
      def real_object
        object = __getobj__
        while object.is_a? SimpleDelegator
          object = object.__getobj__
        end

        object
      end
    end
  end
end
