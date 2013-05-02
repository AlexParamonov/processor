require 'logger'

module Processor
  module Observer
    class NullObserver
      def initialize(processor, options = {})
        @processor = processor
        @messenger = options.fetch :messenger do
          ::Logger.new("/dev/null")
        end
      end

      def method_missing(*); end
      alias_method :update, :send

      private
      attr_reader :processor, :messenger
    end
  end
end
