require 'logger'

module Processor
  module Observer
    class NullObserver
      def initialize(options = {})
        @messenger = options.fetch :messenger do
          ::Logger.new(STDOUT).tap do |logger|
            logger.formatter =  -> _, _, _, msg do
              "> #{msg}\n"
            end
            logger.level = ::Logger::INFO
          end
        end
      end

      def method_missing(*); end
      alias_method :update, :send

      private
      attr_reader :messenger
    end
  end
end
