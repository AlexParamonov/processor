require 'logger'
require 'processor/messenger'

module Processor
  module Observer
    class NullObserver
      def initialize(options = {})
        @messenger = options.fetch :messenger, Processor::Messenger.new(:info)
      end

      def method_missing(*); end
      alias_method :update, :send

      private
      attr_reader :messenger
    end
  end
end
